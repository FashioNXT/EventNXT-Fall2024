# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokenController, type: :controller do
  describe '#exchange' do
    let(:user) { create(:user, name: 'Test', email: 'testuser@example.com') }

    it 'returns JSON with access_token, name, and email' do
      # Mock the OAuth2::AccessToken and its behavior
      access_token_double = double('OAuth2::AccessToken',
        token: 'your_access_token_here')
      allow(access_token_double).to receive(:get).with('/api/user').and_return(double(parsed: {
        'name' => user.name, 'email' => user.email
      }))

      # Mock the from_hash method to return the access_token_double
      allow(OAuth2::AccessToken).to receive(:from_hash).and_return(access_token_double)

      # Perform the post request
      post :exchange, params: { access_token: 'your_access_token_here' }

      # Verify the response
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['access_token']).to eq('your_access_token_here') # Ensure correct access token
      expect(json_response['name']).to eq('Test') # Ensure correct name
      expect(json_response['email']).to eq('testuser@example.com') # Ensure correct email
    end
  end
end
