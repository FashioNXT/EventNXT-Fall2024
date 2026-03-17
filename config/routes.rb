Rails.application.routes.draw do
  root to: 'home#index'
  get '/login', to: 'home#login'
  get '/logout', to: 'home#logout'
  get '/signup', to: 'home#index'
end
