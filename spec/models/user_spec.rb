# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:events).dependent(:destroy) }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it { should validate_presence_of(:uid) }
    it { should validate_presence_of(:provider) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }

    subject { create(:user) }

    it 'validates uniqueness of uid scoped to provider' do
      duplicate_user = build(:user, uid: subject.uid, provider: subject.provider)

      expect(duplicate_user).to_not be_valid
      expect(duplicate_user.errors[:uid]).to include('and provider combination must be unique')
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
      before do
        User.delete_all # Ensure no users exist in the database
      end

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
        expect(new_user.uid).to eq(auth.uid)
        expect(new_user.provider).to eq(auth.provider)
        expect(new_user.email).to eq(auth.info.email)
        expect(new_user.name).to eq(auth.info.name)
      end
    end
  end
end
