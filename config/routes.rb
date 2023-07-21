Rails.application.routes.draw do
  root "movies#index"

  resources :movies, except: %i[new update destroy] do
    post :rent, on: :member
    post :return_movie, on: :member
    get :best, on: :collection
  end

  resources :users, except: %i[new update] do
    get :recommendations, on: :member
    get :watch_next, on: :member
    get :rented_movies, on: :member
  end
end
