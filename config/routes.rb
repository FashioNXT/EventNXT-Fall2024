# frozen_string_literal: true

Rails.application.routes.draw do
  get '/book_seats/:rsvp_link', to: 'guests#book_seats', as: 'book_seats'
  get '/events_controller/new_email_template',
    to: 'events_controller#new_email_template', as: 'new_email_template'
  get '/events_controller/email_template/:id',
    to: 'events_controller#edit_email_template', as: 'edit_email_template'
  get '/events_controller/render_email_template',
    to: 'events_controller#render_template', as: 'render_email_template'
  get 'destroy_email_template/:id',
    to: 'events_controller#destroy_email_template', as: 'destroy_email_template'

  # get '/referral/:ref_code', to: 'referrals#refer', as: 'referral'

  get '/refer_a_friend/:random_code', to: 'referrals#new', as: 'new_referral'
  post '/refer_a_friend/:random_code', to: 'referrals#referral_creation',
    as: 'referral_creation'

  get '/buy_tickets', to: 'tickets#new', as: 'new_ticket_purchase'

  resources :events do
    member do
      post :bulk_action
    end
  end

  resources :events do
    resources :referrals, only: %i[new referral_creation edit update]
  end

  resources :tickets, only: %i[new create]

  root 'home#index'

  post 'events_controller/add_email_template',
    to: 'events_controller#add_email_template', as: 'add_email_template'
  patch '/events_controller/email_template/:id/update', to: 'events_controller#update_email_template',
    as: 'update_email_template'
  patch '/update_commited_seats/:rsvp_link',
    to: 'guests#update_commited_seats', as: 'update_commited_seats'

  ## == Devise OAuth ==
  devise_for :users,
    controllers: { omniauth_callbacks: 'users/omniauth_callbacks' },
    omniauth_providers: %i[events360]

  # Define custom sessions routes
  devise_scope :user do
    delete 'users/sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  end

  # Define custom devise routes for OmniAuth-based authentication failures
  get '/users/auth/failure', to: 'users/omniauth_callbacks#failure'

  resources :events do
    resources :seats
    resources :guests do
      collection do
        post 'import', to: 'guests#import_spreadsheet', as: 'import_spreadsheet'
      end
    end
  end

  # resources :seats
  # resources :guests
end
