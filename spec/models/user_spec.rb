# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:password) { 'password123' }

  describe 'validations' do
    it 'requires a password' do
      user = User.new(email: 'user@example.com', password:,
        password_confirmation: password)
      expect(user).to be_valid

      user.password = ''
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end
  end

  describe User do
    describe '.from_google' do
      context 'when given valid Google info' do
        let(:info) { { uid: '12345', email: 'test@example.com' } }

        it 'creates a new user with the given info' do
          expect do
            User.from_google(info)
          end.to change { User.count }.by(1)

          user = User.find_by(email: info[:email])
          expect(user.uid).to eq(info[:uid])
          expect(user.provider).to eq('google')
        end
      end
    end
  end
  describe '.from_omniauth' do
    let(:access_token) { instance_double('AccessToken', get: response) }
    let(:response) { instance_double('Response', parsed: oauth_response) }
    let(:oauth_response) do
      { 'email' => 'test@example.com', 'name' => 'Test User' }
    end

    context 'when the user does not exist' do
      it 'creates a new user' do
        expect do
          User.from_omniauth(access_token)
        end.to change(User, :count).by(1)
        user = User.find_by(email: 'test@example.com')
        expect(user).not_to be_nil
        expect(user.name).to eq 'Test User'
        # Additional assertions as necessary
      end
    end

    context 'when the user already exists' do
      before do
        User.create(email: 'test@example.com', name: 'Existing User', password: 'password',
          password_confirmation: 'password')
      end

      it 'does not create a new user' do
        expect { User.from_omniauth(access_token) }.not_to change(User, :count)
      end

      it 'updates the user’s details' do
        User.from_omniauth(access_token)
        user = User.find_by(email: 'test@example.com')
        expect(user.name).to eq 'Test User1' # Assuming the name gets updated
        # Additional assertions as necessary
      end
    end

    # More tests could be added to cover edge cases and error handling
  end
end
