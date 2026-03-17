Rails.application.routes.draw do
  use_doorkeeper
  root to: 'home#index'
  
  get '/login', to: 'home#index'
  get '/signup', to: 'home#index'
  get '/logout', to: 'home#index'
end
