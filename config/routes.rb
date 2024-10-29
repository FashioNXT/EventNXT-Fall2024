Rails.application.routes.draw do
  root 'home#index'

  # Guest-related routes
  get '/book_seats/:rsvp_link', to: 'guests#book_seats', as: 'book_seats'
  patch '/update_commited_seats/:rsvp_link', to: 'guests#update_commited_seats', as: 'update_commited_seats'

  # Referral-related routes
  get '/refer_a_friend/:random_code', to: 'referrals#new', as: 'new_referral'
  post '/refer_a_friend/:random_code', to: 'referrals#referral_creation', as: 'referral_creation'

  # Ticket-related routes
  get '/buy_tickets', to: 'tickets#new', as: 'new_ticket_purchase'
  resources :tickets, only: %i[new create]

  # Event-related routes with nested resources for referrals, seats, and guests
  resources :events do
    resources :referrals, only: %i[new create edit update]
    resources :seats
    resources :guests do
      collection do
        post 'import', to: 'guests#import_spreadsheet', as: 'import_spreadsheet'
      end
    end
  end

  # Email services and template management
  resources :email_services do
    member do
      get 'send_email'
    end
    collection do
      #get 'new_email_template', to: 'email_services#new_email_template', as: 'new_email_template'
      get 'render_email_template', to: 'email_services#render_template', as: 'render_email_template'
      post 'add_email_template', to: 'email_services#add_email_template', as: 'add_email_template'
    end
  end

  # Standalone route for new email template
  get '/email_services/new_email_template', to: 'email_services#new_email_template', as: 'new_email_template'
  # Email template-specific routes
  get '/email_services/email_template/:id', to: 'email_services#edit_email_template', as: 'edit_email_template'
  patch '/email_services/email_template/:id/update', to: 'email_services#update_email_template', as: 'update_email_template'
  delete '/destroy_email_template/:id', to: 'email_services#destroy_email_template', as: 'destroy_email_template'

  # Devise authentication and OAuth
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }, omniauth_providers: %i[events360]

  # Custom Devise routes
  devise_scope :user do
    delete 'users/sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  end

  # Define route for OmniAuth authentication failure
  get '/users/auth/failure', to: 'users/omniauth_callbacks#failure'
end
