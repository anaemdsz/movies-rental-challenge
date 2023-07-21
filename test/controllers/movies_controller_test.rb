require "test_helper"

class MoviesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @movie = movies(:standard)
    @movie_no_copies = movies(:movie_with_no_copies)
    @user = users(:standard)
    
  end

  test "should get index" do
    get movies_url, as: :json
    assert_response :success
  end

  test "should show movie" do
    get movie_url(@movie), as: :json
    assert_response :success
  end

  test "should create movie" do
    assert_difference("Movie.count") do
      post movies_url, params: { movie: {
        title: "Foo 2: Revenge of Bar",
        genre: "Sci-fi",
        rating: 4.5,
        available_copies: 4
      } }, as: :json
    end
    assert_response :created
  end

  test "shouldn't create movie" do
    assert_no_difference("Movie.count") do
      assert_raises(ActiveRecord::NotNullViolation) do
        post movies_url, params: { movie: {
          genre: "Sci-fi"
        }}
      end
    end
  end

  test "should rent movie to user" do
    assert_difference("@user.rented.count", 1) do
      post rent_movie_path(@movie.id), params: { user_id: @user.id}, as: :json
    end
    assert_response :success
  end 

  test "shouldn't double rent" do
    post rent_movie_path(@movie.id), params: { user_id: @user.id}, as: :json
    assert_no_difference("@user.rented.count") do
      post rent_movie_path(@movie.id), params: { user_id: @user.id}, as: :json
    end
    assert_response :unprocessable_entity
    assert_equal "User already rented this movie.", JSON.parse(response.body)["error"]

  end
  
  test "shouldn't rent movie to user when no copies available" do
    assert_no_difference("@user.rented.count") do
      post rent_movie_path(@movie_no_copies.id), params: { user_id: @user.id}, as: :json
    end

    assert_response :unprocessable_entity
    assert_equal "Movie is not available for rent.", JSON.parse(response.body)["error"]
  end

  test "user can return their movie" do
    jons_movie = movies(:movie_jon_has)
    assert_difference("@user.rented.count", -1) do
      post return_movie_movie_path(jons_movie.id), params: { user_id: @user.id}, as: :json
    end
    assert_response :success
  end

  test "can get best movies without availability" do
    get best_movies_path, as: :json
    assert_response :success
  end

  test "can get best available movies" do
    get best_movies_path, params: { availability: true }
    assert_response :success
  end
end
