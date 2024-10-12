require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  describe '#events360' do
    let(:user) { create(:user) }

    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]

      allow(ENV).to receive(:[]).with("NXT_APP_URL").and_return("http://example.com")
      allow(ENV).to receive(:[]).with("NXT_APP_ID").and_return("client_id")
      allow(ENV).to receive(:[]).with("NXT_APP_SECRET").and_return("client_secret")
      allow(ENV).to receive(:[]).with("EVENT_NXT_APP_URL").and_return("http://callback-example.com")
    end

    it 'exchanges code for token and signs in the user' do
      oauth_client_mock = double('OAuth2::Client')
      auth_code_mock = double('OAuth2::Strategy::AuthCode')
      oauth_access_token_mock = double('OAuth2::AccessToken')

      allow(OAuth2::Client).to receive(:new).and_return(oauth_client_mock)
      allow(oauth_client_mock).to receive(:auth_code).and_return(auth_code_mock)
      allow(auth_code_mock).to receive(:get_token)
        .with('auth_code', redirect_uri: 'http://callback-example.com/auth/events360/callback')
        .and_return(oauth_access_token_mock)

      allow(User).to receive(:from_omniauth).with(oauth_access_token_mock).and_return(user)

      # Expect the method to be called and allow it to execute normally
      expect(controller).to receive(:sign_in_and_redirect).with(user, event: :authentication).and_call_original

      # Simulate a GET request with an authorization code
      get :events360, params: { code: 'auth_code' }

      # Test if the user is authenticated and redirected
      expect(User).to have_received(:from_omniauth).with(oauth_access_token_mock)

      # Ensure the response is a redirect
      expect(response).to have_http_status(:redirect)
    end

    it 'redirects to new_user_session_path when user is not found' do
      oauth_client_mock = double('OAuth2::Client')
      auth_code_mock = double('OAuth2::Strategy::AuthCode')
      oauth_access_token_mock = double('OAuth2::AccessToken')

      allow(OAuth2::Client).to receive(:new).and_return(oauth_client_mock)
      allow(oauth_client_mock).to receive(:auth_code).and_return(auth_code_mock)
      allow(auth_code_mock).to receive(:get_token)
        .with('auth_code', redirect_uri: 'http://callback-example.com/auth/events360/callback')
        .and_return(oauth_access_token_mock)

      allow(User).to receive(:from_omniauth).with(oauth_access_token_mock).and_return(nil)

      get :events360, params: { code: 'auth_code' }

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq("Invalid username/email or password")
    end

    it 'handles OAuth2 errors gracefully' do
      oauth_client_mock = double('OAuth2::Client')
      auth_code_mock = double('OAuth2::Strategy::AuthCode')

      allow(OAuth2::Client).to receive(:new).and_return(oauth_client_mock)
      allow(oauth_client_mock).to receive(:auth_code).and_return(auth_code_mock)
      allow(auth_code_mock).to receive(:get_token)
        .and_raise(OAuth2::Error.new(double('response', parsed: {}, body: 'invalid_grant')))

      get :events360, params: { code: 'invalid_code' }

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq("Failed to authenticate via Event360.")
    end
  end
end
