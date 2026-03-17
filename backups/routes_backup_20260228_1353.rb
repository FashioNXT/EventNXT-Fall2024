Rails.application.routes.draw do
  namespace :api do 
    get "user", to: "users#show" 
  end  use_doorkeeper
  devise_for :users

  root to: "home#index"

  resources :guests
  resources :email_services
  resources :referrals
  resources :seats
  resources :tickets
end
