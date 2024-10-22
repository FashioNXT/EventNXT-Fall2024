# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'is invalid without a uid' do
      user = build(:user, uid: nil)
      expect(user).to_not be_valid
      expect(user.errors[:uid]).to include("can't be blank")
    end

    it 'is invalid without a provider' do
      user = build(:user, provider: nil)
      expect(user).to_not be_valid
      expect(user.errors[:provider]).to include("can't be blank")
    end

    it 'is invalid without an email' do
      user = build(:user, email: nil)
      expect(user).to_not be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'is invalid with a non-unique email' do
      create(:user, email: 'user@example.com')
      user = build(:user, email: 'user@example.com')
      expect(user).to_not be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end

    it 'is invalid if the uid and provider combination is not unique' do
      create(:user, provider: 'fake_provider', uid: '123456')
      user = build(:user, provider: 'fake_provider', uid: '123456')
      expect(user).to_not be_valid
      expect(user.errors[:uid]).to include('and provider combination must be unique')
    end
  end

  describe '.from_omniauth' do
    context 'when auth provider is events360,' do
      let(:user) { create(:user, :events360) }
      let(:auth) do
        OmniAuth::AuthHash.new(
          provider: user.provider,
          uid: user.uid,
          info: {
            email: user.email,
            name: user.name
          }
        )
      end

      it 'calls from_omniauth_events360' do
        expect(User).to receive(:from_omniauth_events360).with(auth).and_call_original
        User.from_omniauth(auth)
      end
    end

    context 'when auth provider is not handled,' do
      let(:auth_other) do
        OmniAuth::AuthHash.new(
          provider: 'unknown',
          uid: '654321',
          info: {
            email: 'user@example.com',
            name: 'John Doe'
          }
        )
      end

      it 'returns nil when provider is not supported' do
        user = User.from_omniauth(auth_other, user)
        expect(user).to be_nil
      end
    end
  end

  describe '.from_omniauth_events360' do
    let(:user) { create(:user, :events360, email: 'old_email@fake.com') }

    context 'when user exists' do
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

      before do
        user # This creates the user in the test database
      end

      it 'updates the user information and returns the user' do
        user = User.from_omniauth(auth)
        expect(user.email).to eq('new_email@fake.com') # updated email
        expect(user.name).to eq('new name') # updated name
        expect(user).to eq(user) # Ensure the same user is returned
      end
    end

    context 'when user does not exist,' do
      let(:auth) do
        OmniAuth::AuthHash.new(
          provider: user.provider,
          uid: user.uid,
          info: {
            email: user.email,
            name: user.name
          }
        )
      end

      it 'creates a new user with the auth information' do
        expect do
          User.from_omniauth(auth)
        end.to change { User.count }.by(1)

        new_user = User.last
        expect(new_user.uid).to eq(user.uid)
        expect(new_user.provider).to eq(user.provider)
        expect(new_user.email).to eq(user.email)
        expect(new_user.name).to eq(user.name)
      end
    end
  end
end
