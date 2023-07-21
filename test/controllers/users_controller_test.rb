require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:standard) # Reuse the fixture for a user with rented movies
  end

  test "should get index" do
    get users_url, as: :json
    assert_response :success
  end

  test "should show user" do
    get user_url(@user), as: :json
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: { user: { name: "foo" } }, as: :json
    end

    assert_response :created
  end

  test "shouldn't create user with invalid parameters" do
    assert_no_difference("User.count") do
      assert_raises(ActiveRecord::NotNullViolation) do
        post users_url, params: { user: { abc: 0 } }, as: :json
      end
    end
  end

  test "shouldn't destroy non-existing user" do
    assert_no_difference("User.count") do
      assert_raises(ActiveRecord::RecordNotFound) do
        delete user_url(12345), as: :json
      end
    end
  end

  test "should destroy user" do
    assert_difference("User.count", -1) do
      delete user_url(@user), as: :json
    end
    assert_response :redirect
  end

  test "should have rented movies for user with rented movies" do
    get rented_movies_user_path(@user), as: :json
    assert_response :success
  end

  test "should have no rented movies for user without rented movies" do
    @user_without_rented_movies = User.new(name: "new_user")
    @user_without_rented_movies.save
    get rented_movies_user_path(@user_without_rented_movies), as: :json
    assert_response :success
    rented_movies = JSON.parse(response.body)
    assert_empty rented_movies
  end
end
