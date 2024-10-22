require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  before do
    # Enable test mode for OmniAuth
    OmniAuth.config.test_mode = true
    # Mock OmniAuth response
    request.env['omniauth.auth'] = OmniAuth::AuthHash.new({
      provider: 'events360',
      uid: '123456',
      info: {
        email: 'user@example.com',
        name: 'John Doe'
      }
    })

    # Ensure Devise mapping for user is set in the test
    @request.env['devise.mapping'] = Devise.mappings[:user]

    # Mock the from_omniauth() method in the controller
    allow(User).to receive(:from_omniauth).and_return(user)
  end

  let(:user) { create(:user, :events360) }

  describe '#events360' do
    context 'when user exists and is persisted' do
      it 'signs in the user and redirects to the root path' do
        get :events360
        expect(controller.current_user).to eq(user)
        expect(response).to redirect_to(events_path)
      end
    end

    context 'when user is not persisted' do
      before do
        invalid_user = User.new
        invalid_user.errors.add(:base, 'User could not be saved')
        allow(User).to receive(:from_omniauth).and_return(invalid_user)
      end

      it 'does not sign in the user and redirects to root with alert' do
        get :events360
        expect(controller.current_user).to be_nil
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe '#failure' do
    it 'redirects to the root path with an alert' do
      get :failure
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('Authentication failed. Please try again.')
    end
  end
end
