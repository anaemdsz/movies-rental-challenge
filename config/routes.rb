Rails.application.routes.draw do
  root "movies#index"

  resources :movies, except: %i[new update destroy] do
    get :recommendations, on: :collection
    get :user_rented_movies, on: :collection
    get :rent, on: :member
  end

  resources :users, except: %i[new update]
end
