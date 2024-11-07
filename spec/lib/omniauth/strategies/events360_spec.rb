# spec/omniauth/strategies/events360_spec.rb
require 'rails_helper'
require 'omniauth'
require 'omniauth-oauth2'
require Rails.root.join('lib', 'omniauth', 'strategies', 'events360')

RSpec.describe OmniAuth::Strategies::Events360 do
  let(:strategy) { described_class.new(nil, client_id: 'test_id', client_secret: 'test_secret') }

  before do
    OmniAuth.config.test_mode = true
    allow(strategy).to receive(:callback_url).and_return('http://example.com/auth/events360/callback')
  end

  describe 'client options' do
    it 'has correct site' do
      expect(strategy.options.client_options.site).to eq(Constants::Events360::URL)
    end

    it 'has correct authorize url' do
      expect(strategy.options.client_options.authorize_url).to eq("#{Constants::Events360::URL}/oauth/authorize")
    end

    it 'has correct token url' do
      expect(strategy.options.client_options.token_url).to eq("#{Constants::Events360::URL}/oauth/token")
    end
  end

  describe '#uid' do
    it 'returns the user id from raw_info' do
      allow(strategy).to receive(:raw_info).and_return({ 'id' => '54321' })
      expect(strategy.uid).to eq('54321')
    end
  end

  describe '#info' do
    it 'returns the correct user info' do
      allow(strategy).to receive(:raw_info).and_return({ 'name' => 'Another User', 'email' => 'another@example.com' })
      expect(strategy.info).to eq({ name: 'Another User', email: 'another@example.com' })
    end
  end
end
