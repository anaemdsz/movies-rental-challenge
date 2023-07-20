class UsersController < ApplicationController
  def index
    @users = User.all
    render json: @users
  end

  def show
    @user = User.find(params[:id])
    render json: @user
  end

  def create
    @user = User.new(user_params)

    if @user.save
      response.headers['Location'] = user_url(@user)
      render json: { message: "User was successfully created." }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id]) 
    
    # Free up user
    @user.favorites.destroy_all

    @user.rentals.each do |rental|
      rental.movie.increment!(:available_copies)
      rental.destroy
    end

    # Destroy user
    @user.destroy
    redirect_to root_url, notice: "User was successfully destroyed."
  end

  private

  def user_params
    params.require(:user).permit(:name)
  end
end