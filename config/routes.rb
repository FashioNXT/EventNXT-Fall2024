# frozen_string_literal: true

Rails.application.routes.draw do
  get '/book_seats/:rsvp_link', to: 'guests#book_seats', as: 'book_seats'
  get '/events/new_email_template',
    to: 'events#new_email_template', as: 'new_email_template'
  get '/events/email_template/:id',
    to: 'events#edit_email_template', as: 'edit_email_template'
  get '/events/render_email_template',
    to: 'events#render_template', as: 'render_email_template'
  get 'destroy_email_template/:id',
    to: 'events#destroy_email_template', as: 'destroy_email_template'

  # get '/referral/:ref_code', to: 'referrals#refer', as: 'referral'

  get '/refer_a_friend/:random_code', to: 'referrals#new', as: 'new_referral'
  post '/refer_a_friend/:random_code', to: 'referrals#referral_creation',
    as: 'referral_creation'

  get '/buy_tickets', to: 'tickets#new', as: 'new_ticket_purchase'

  resources :email_services do
    member do
      get 'send_email'
      # get 'show'
      # get 'index'
    end
  end

  resources :events do
    post 'bulk_action', on: :member

    resources :email_templates, only: [:new, :create, :edit, :update, :destroy] do

      post 'send_email', on: :member
    end 
  end

  resources :events do
    resources :referrals, only: %i[new referral_creation edit update]
  end

  resources :tickets, only: %i[new create]

  root 'home#index'

  post 'events/add_email_template',
    to: 'events#add_email_template', as: 'add_email_template'
  patch '/events/email_template/:id/update', to: 'events#update_email_template',
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
