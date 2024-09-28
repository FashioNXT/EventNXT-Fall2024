require 'rails_helper'

RSpec.describe TokenController, type: :controller do
  describe '#exchange' do
    let(:user) { create(:user) }

    it 'returns JSON with access_token' do
      access_token_double = double('OAuth2::AccessToken', token: 'your_access_token_here')
      allow(access_token_double).to receive(:get).with('/api/user').and_return(double(parsed: { name: user.name, email: user.email }))
      allow(OAuth2::AccessToken).to receive(:from_hash).and_return(access_token_double)

      post :exchange, params: { access_token: 'your_access_token_here' }

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['access_token']).to eq('your_access_token_here') # Modify with the expected access token
    end

    # Add more tests as needed
  end
end
