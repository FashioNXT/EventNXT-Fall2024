require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  before do
    # Enable test mode for OmniAuth
    OmniAuth.config.test_mode = true

    # Ensure Devise mapping for user is set in the test
    @request.env['devise.mapping'] = Devise.mappings[:user]

  end

  let(:user) { create(:user, Constants::Events360::SYM) }
   
  describe '.events360' do
    before do
      # Mock OmniAuth response
      request.env['omniauth.auth'] = OmniAuth::AuthHash.new({
        provider: Constants::Events360::NAME,
        uid: user.uid,
        info: {
          email: user.email,
          name: user.name
        }
      })
    end

    context 'when user exists and is persisted,' do
      before do
         allow(User).to receive(:from_omniauth).and_return(user)
      end
      it 'signs in the user and redirects to the root path' do
        get Constants::Events360::SYM
        expect(controller.current_user).to eq(user)
        expect(response).to redirect_to(events_path)
      end
    end

    context 'when user does not exist, ' do
      before do
        allow(User).to receive(:from_omniauth).and_return(nil)
      end

      it 'does not sign in the user and redirects to root with alert' do
        get Constants::Events360::SYM
        expect(controller.current_user).to be_nil
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end

    context 'when in development mode,' do
      before do
        # Set Rails environment to development for the test
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))

        # Mock OmniAuth responses for different users
        OmniAuth.config.mock_auth[Constants::Events360::Mock::USER1] = OmniAuth::AuthHash.new({
          provider: Constants::Events360::NAME,
          uid: 'user1_uid',
          info: {
            email: 'user1@example.com',
            name: 'User One'
          }
        })

        OmniAuth.config.mock_auth[Constants::Events360::Mock::USER2] = OmniAuth::AuthHash.new({
          provider: Constants::Events360::NAME,
          uid: 'user2_uid',
          info: {
            email: 'user2@example.com',
            name: 'User Two'
          }
        })

        OmniAuth.config.mock_auth[Constants::Events360::Mock::USER3] = OmniAuth::AuthHash.new({
          provider: Constants::Events360::NAME,
          uid: 'user3_uid',
          info: {
            email: 'user3@example.com',
            name: 'User Three'
          }
        })
      end

      it 'authenticates as user1' do
        session[:user] = 'user1'
        get Constants::Events360::SYM

        # Expect the user to be found or created with the mock_auth for user1
        user = User.find_by(uid: 'user1_uid', provider: Constants::Events360::NAME)
        expect(user).to be_present

        # Expect user to be signed in
        expect(controller.current_user).to eq(user)
        expect(response).to redirect_to(events_path)
      end

      it 'authenticates as user2' do
        session[:user] = 'user2'
        get Constants::Events360::SYM

        # Expect the user to be found or created with the mock_auth for user1
        user = User.find_by(uid: 'user2_uid', provider: Constants::Events360::NAME)
        expect(user).to be_present

        # Expect user to be signed in
        expect(controller.current_user).to eq(user)
        expect(response).to redirect_to(events_path)
      end

      it 'authenticates as user3' do
        session[:user] = 'user3'
        get Constants::Events360::SYM

        # Expect the user to be found or created with the mock_auth for user1
        user = User.find_by(uid: 'user3_uid', provider: Constants::Events360::NAME)
        expect(user).to be_present

        # Expect user to be signed in
        expect(controller.current_user).to eq(user)
        expect(response).to redirect_to(events_path)
      end
    end
  end

  describe 'eventbrite' do
    let(:user) { create(:user, Constants::Eventbrite::SYM) }
    before do
      # Mock OmniAuth response
      request.env['omniauth.auth'] = OmniAuth::AuthHash.new({
        provider: Constants::Eventbrite::NAME,
        uid: '123456'
      })

      # Mock the from_omniauth() method in the controller
      allow(User).to receive(:from_omniauth).and_return(user)
    end 

    context 'when user exists and is persisted,' do
      it 'show notice' do
        get Constants::Eventbrite::SYM
        expect(flash[:notice]).to be_present
        expect(response).to redirect_to(events_path)
      end
    end

    context 'when user does not exist' do
      before do
        allow(User).to receive(:from_omniauth).and_return(nil)
      end

      it 'show alert' do
        get Constants::Eventbrite::SYM
        expect(flash[:alert]).to be_present
        expect(response).to redirect_to(events_path)
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
