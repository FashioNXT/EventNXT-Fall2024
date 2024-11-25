# frozen_string_literal: true

# Model for Users
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, omniauth_providers: [Constants::Events360::SYM, Constants::Eventbrite::SYM]

  # Custom Validations
  validates :uid, presence: true
  validates :provider, presence: true
  validates :uid, uniqueness: { scope: :provider, message: 'and provider combination must be unique' }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  has_many :events, dependent: :destroy
  class << self
    def from_omniauth(auth, current_user = nil)
      provider = auth.provider.to_s

      if current_user.nil?
        return nil unless provider == Constants::Events360::NAME

        return self.from_omniauth_events360(auth)
      end

      case auth.provider.to_s
      when Constants::Eventbrite::NAME
        return current_user.from_omniauth_eventbrite(auth)
      end
      nil
    end

    private

    def from_omniauth_events360(auth)
      user_info = {
        uid: auth.uid.to_s,
        provider: auth.provider.to_s,
        email: auth.info.email,
        name: auth.info.name
      }

      user = self.find_by(uid: user_info[:uid], provider: user_info[:provider])

      if user.nil?
        user = self.create(user_info)
        user.persisted? ? user : nil
      else
        user.update(user_info)
        user
      end
    end
  end

  def from_omniauth_eventbrite(auth)
    self.update(
      eventbrite_uid: auth.uid,
      eventbrite_token: auth.credentials.token
    )
    self
  end
end
