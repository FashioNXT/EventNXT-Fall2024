Rails.application.routes.draw do
  get 'token/exchange'
  get 'remember_me/clear_remember_me'
  get '/book_seats/:rsvp_link', to: 'guests#book_seats', as: 'book_seats'
  get '/email_services/new_email_template', to: 'email_services#new_email_template', as: 'new_email_template'
  get '/email_services/email_template/:id', to: 'email_services#edit_email_template', as: 'edit_email_template'
  get '/email_services/render_email_template', to: 'email_services#render_template', as: 'render_email_template'
  get 'destroy_email_template/:id', to: 'email_services#destroy_email_template', as: 'destroy_email_template'
  
  resources :email_services do
    member do
      get 'send_email'
      #get 'show'
      #get 'index'
    end
  end

  
  
  root 'home#index'

  post 'email_services/add_email_template', to: 'email_services#add_email_template', as: 'add_email_template'
  patch '/email_services/email_template/:id/update', to: 'email_services#update_email_template', as: 'update_email_template'
  patch '/update_commited_seats/:rsvp_link', to: 'guests#update_commited_seats', as: 'update_commited_seats'
  
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  devise_scope :user do
    post 'oauth/authorize', to: 'users/authorizelogin#authorize_event360'
    get 'oauth/authorize', to: 'users/authorizelogin#authorize_event360'
    get 'auth/events360/callback', to: 'users/omniauth_callbacks#events360'
    post 'auth/events360/callback', to: 'users/omniauth_callbacks#events360'
  end

  resources :events do
    resources :seats
    resources :guests
  end

  post '/import_previous_event_information', to: 'events#import_previous_event_information'
  post '/events/:event_id/import_previous_guest_information', to: 'guests#import_previous_guest_information', as: 'import_previous_guest_information_for_the_event'

  #resources :seats
  #resources :guests
end
