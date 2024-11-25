# spec/omniauth/strategies/eventbrite_spec.rb
require 'rails_helper'
require 'omniauth'
require 'omniauth-oauth2'
require Rails.root.join('lib', 'omniauth', 'strategies', 'eventbrite')

RSpec.describe OmniAuth::Strategies::Eventbrite do
  let(:strategy) { described_class.new(nil, client_id: 'test_id', client_secret: 'test_secret') }

  before do
    OmniAuth.config.test_mode = true
    allow(strategy).to receive(:callback_url).and_return('http://example.com/auth/eventbrite/callback')
  end

  describe 'client options' do
    it 'has correct site' do
      expect(strategy.options.client_options.site).to eq(Constants::Eventbrite::API_URL)
    end

    it 'has correct authorize url' do
      expect(strategy.options.client_options.authorize_url).to eq("#{Constants::Eventbrite::URL}/oauth/authorize")
    end

    it 'has correct token url' do
      expect(strategy.options.client_options.token_url).to eq("#{Constants::Eventbrite::URL}/oauth/token")
    end
  end

  describe '#uid' do
    it 'returns the user id from raw_info' do
      allow(strategy).to receive(:raw_info).and_return({ 'id' => '12345' })
      expect(strategy.uid).to eq('12345')
    end
  end

  describe '#info' do
    it 'returns the correct user info' do
      allow(strategy).to receive(:raw_info).and_return({ 'name' => 'Test User', 'email' => 'test@example.com' })
      expect(strategy.info).to eq({ name: 'Test User', email: 'test@example.com' })
    end
  end

  describe '#build_access_token' do
    let(:client_spy) { instance_spy(OAuth2::Client) }

    before do
      allow(strategy).to receive(:client).and_return(client_spy)
      allow(strategy).to receive(:request).and_return(double('Request', params: { 'code' => 'test_code' })) 
      allow(strategy).to receive(:fail!)
      # Allow and expect get_token call to proceed normally in the first test
      allow(client_spy).to receive(:get_token).and_return(double('AccessToken', token: 'test_token'))
      # Mock the client.get_token to simulate an OAuth2::Error
      allow(client_spy).to receive(:get_token).and_raise(
        OAuth2::Error.new(
          double(
            'Response', 
            parsed: { 'error' => 'invalid_request', 'error_description' => 'client_id: Invalid API key- not in our system' }
          )
        )
      )
    end

    it 'includes client_id and client_secret in the token request' do
      strategy.build_access_token
      expect(client_spy).to have_received(:get_token).with(
        hash_including(
          client_id: 'test_id', 
          client_secret: 'test_secret', 
          grant_type: 'authorization_code', 
          code: 'test_code'
        ), 
        anything
      )    
    end

    it 'handles invalid credentials by calling fail!' do
      strategy.build_access_token
      expect(strategy).to have_received(:fail!).with(:invalid_credentials, instance_of(OAuth2::Error))
    end
  end
end