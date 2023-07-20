class MoviesController < ApplicationController
  def index
    @movies = Movie.all
    render json: @movies
  end

  def show
    @movie = Movie.find(params[:id])
    render json: @movie
  end

  def create
    @movie = Movie.new(movie_params)

    if @movie.save
      response.headers['Location'] = movie_url(@movie)
      render json: { message: "Movie was successfully created." }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def recommendations
    favorite_movies = User.find(params[:user_id]).favorites
    @recommendations = RecommendationEngine.new(favorite_movies).recommendations
    render json: @recommendations
  end

  def user_rented_movies
    @rented = User.find(params[:user_id]).rented
    render json: @rented
  end

  def rent
    user = User.find(params[:user_id])
    movie = Movie.find(params[:id])
    movie.available_copies -= 1
    movie.save
    user.rented << movie
    render json: movie
  end

  private

  def movie_params
    params.require(:movie).permit(:title, :genre, :rating, :available_copies)
  end
end