# frozen_string_literal: true

require 'rails_helper'

def mock_auth(user, uid: nil, provider: nil, token: nil)
  OmniAuth::AuthHash.new(
    provider: provider || user.provider,
    uid: uid || user.uid,
    info: {
      email: user.email,
      name: user.name
    },
    credentials: {
      token: token
    }
  )
end

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:events).dependent(:destroy) }
  end

  describe 'validations' do
    subject { create(:user) }

    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:email) }

    it 'validates uniqueness of uid scoped to provider' do
      duplicate_user = build(:user, uid: subject.uid, provider: subject.provider)

      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:uid]).to include('and provider combination must be unique')
    end
  end

  describe '.from_omniauth' do
    let(:user) { create(:user) }
    before do
      allow(described_class).to receive(:from_omniauth_events360)
      allow(user).to receive(:from_omniauth_eventbrite)
    end

    context  'when no current user and the provider is Events360' do
      let(:auth) { mock_auth(user) }

      it 'should call from_omniauth_events360' do
        described_class.from_omniauth(auth)
        expect(described_class).to have_received(:from_omniauth_events360).with(auth)
      end
    end

    context  'when no current user and the provider is not Events360' do
      let(:auth) { mock_auth(user, provider: Constants::Eventbrite::NAME) }

      it 'should return nil without further callings' do
        result_user =  described_class.from_omniauth(auth)
        expect(described_class).not_to have_received(:from_omniauth_events360)
        expect(user).not_to have_received(:from_omniauth_eventbrite)
        expect(result_user).to be nil
      end
    end

    context 'when auth provider is Eventbrite' do
      let(:auth) { mock_auth(user, provider: Constants::Eventbrite::NAME) }
      
      it 'should call from_omniauth_eventbrite' do
        described_class.from_omniauth(auth, user)
        expect(user).to have_received(:from_omniauth_eventbrite).with(auth)
      end
    end

    context 'when auth provider is not handled,' do
      let(:auth) { mock_auth(user, provider: 'unknown provider') }
      
      it 'returns nil when provider is not supported' do
        result_user = described_class.from_omniauth(auth, user)
        expect(described_class).not_to have_received(:from_omniauth_events360)
        expect(user).not_to have_received(:from_omniauth_eventbrite)
        expect(result_user).to be_nil
      end
    end
  end

  describe '.from_omniauth_events360' do
    context 'when user does not exist, ' do
      let(:user) { build(:user) }
      let(:auth) { mock_auth(user) }

      it 'creates a new user with the auth information' do
        result_user = described_class.from_omniauth(auth)
        expect(described_class.count).to eq(1)
        expect(result_user.uid).to eq(auth.uid)
        expect(result_user.provider).to eq(auth.provider)
        expect(result_user.email).to eq(auth.info.email)
      end
    end

    context 'when user exists' do
      let(:user) { create(:user, email: 'old_email@fake.com') }
      let(:auth) do
        OmniAuth::AuthHash.new(
          provider: user.provider,
          uid: user.uid,
          info: {
            email: 'new_email@fake.com',
            name: 'new name'
          }
        )
      end

      it 'updates the user information and returns the user' do
        result_user = described_class.from_omniauth(auth)
        user.reload
        expect(result_user).to eq(user)
        expect(user.email).to eq('new_email@fake.com')
        expect(user.name).to eq('new name') 
      end
    end
  end

  describe '.from_omniauth_eventbrite' do
    context 'when current user does not have token' do
      let(:user) { create(:user) }
      let(:eventbrite_uid) {'eventbrite_uid' }
      let(:eventbrite_token) { 'token' }
      let(:auth) { 
        mock_auth(
          user, 
          uid: eventbrite_uid, 
          provider: Constants::Eventbrite::NAME, 
          token: eventbrite_token
        ) 
      }

      it 'adds uid and access token into current user' do
        result_user = user.from_omniauth_eventbrite(auth)
        user.reload
        expect(result_user).to eq(user)
        expect(user.eventbrite_uid).to eq(eventbrite_uid)
        expect(user.eventbrite_token).to eq(eventbrite_token)
      end
    end

    context 'when current user has an access token' do
      let(:old_uid) { 'old_uid' }
      let(:old_token) { 'old_token' }
      let(:new_uid) { 'new_uid' }
      let(:new_token) { 'new_token' }

      let(:user) do
        create(:user, 
          Constants::Eventbrite::SYM, 
          eventbrite_uid: old_uid, 
          eventbrite_token: old_token
        ) 
      end 
      
      let(:auth) { 
        mock_auth(
          user, 
          uid: new_uid,
          provider: Constants::Eventbrite::NAME, 
          token: new_token
        ) 
      }
      
      it 'updates access token into current user' do
        result_user = user.from_omniauth_eventbrite(auth)
        user.reload
        expect(result_user).to eq(user)
        expect(user.eventbrite_uid).to eq(new_uid)
        expect(user.eventbrite_token).to eq(new_token)
      end
    end
  end
end
