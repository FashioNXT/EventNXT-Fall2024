# frozen_string_literal: true

Rails.application.routes.draw do
  get '/book_seats/:rsvp_link', to: 'guests#book_seats', as: 'book_seats'
  get '/email_services/new_email_template',
    to: 'email_services#new_email_template', as: 'new_email_template'
  get '/email_services/email_template/:id',
    to: 'email_services#edit_email_template', as: 'edit_email_template'
  get '/email_services/render_email_template',
    to: 'email_services#render_template', as: 'render_email_template'
  get 'destroy_email_template/:id',
    to: 'email_services#destroy_email_template', as: 'destroy_email_template'

  # get '/referral/:ref_code', to: 'referrals#refer', as: 'referral'

  get '/refer_a_friend/:random_code', to: 'referrals#new', as: 'new_referral'
  post '/refer_a_friend/:random_code', to: 'referrals#referral_creation',
    as: 'referral_creation'

  resources :email_services do
    member do
      get 'send_email'
      # get 'show'
      # get 'index'
    end
  end

  resources :events do
    resources :referrals, only: %i[new referral_creation edit update]
  end

  root 'home#index'

  post 'email_services/add_email_template',
    to: 'email_services#add_email_template', as: 'add_email_template'
  patch '/email_services/email_template/:id/update', to: 'email_services#update_email_template',
    as: 'update_email_template'
  patch '/update_commited_seats/:rsvp_link',
    to: 'guests#update_commited_seats', as: 'update_commited_seats'

  ## == Devise OAuth ==
  devise_for :users,
    controllers: { omniauth_callbacks: 'users/omniauth_callbacks' },
    omniauth_providers: %i[events360 eventbrite]

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
end
