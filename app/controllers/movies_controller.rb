class MoviesController < ApplicationController
  def index
    genre = params[:genre] || nil
    @movies = Movie.all

    @movies = @movies.where(genre: genre) if genre
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

  def rent
    user = User.find_by(id: params[:user_id])
    movie = Movie.find_by(id: params[:id])
    if user.nil?
      render json: { error: "User not found.", status: 404 }, status: :not_found
    elsif movie.nil?
      render json: { error: "Movie not found.", status: 404 }, status: :not_found
    elsif user.rented.include?(movie)
      render json: { error: "User already rented this movie.", status: 422}, status: :unprocessable_entity
    elsif movie.available_copies > 0
      movie.available_copies -= 1
      movie.save
      user.rented << movie
      render json: movie
    else
      render json: { error: "Movie is not available for rent.", status: 422 }, status: :unprocessable_entity
    end
  end

  def return_movie
    user = User.find_by(id: params[:user_id])
    movie = Movie.find_by(id: params[:id])

    if user.nil?
      render json: { error: "User not found.", status: 404 }, status: :not_found
    elsif movie.nil?
      render json: { error: "Movie not found.", status: 404 }, status: :not_found
    elsif user.rentals.find_by(movie_id: movie.id).present?
      movie.available_copies += 1
      movie.save
      user.rentals.find_by(movie_id: movie.id).destroy
      render json: movie
    else
      render json: { error: "User doesn't have this movie rented.", status: 422 }, status: :unprocessable_entity
    end
  end

  def best
    availability = params[:availability] || false
    @movies = Movie.all

    @movies = @movies.where("available_copies > 0") if availability
    @movies = @movies.order(rating: :desc).limit(10)
    render json: @movies
  end

  private

  def movie_params
    params.require(:movie).permit(:title, :genre, :rating, :available_copies)
  end
end