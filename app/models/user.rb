# frozen_string_literal: true

# Model for Users
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, omniauth_providers: %i[events360 eventbrite]

  # Custom Validations
  validates :uid, presence: true
  validates :provider, presence: true
  validates :uid, uniqueness: { scope: :provider, message: 'and provider combination must be unique' }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  has_many :events

  class << self
    def from_omniauth(auth, current_user = nil)
      case auth.provider.to_s
      when 'events360'
        self.from_omniauth_events360(auth)
      when 'eventbrite'
        self.from_omniauth_eventbrite(auth, current_user)
      end
    end

    # TODO: eventbrite integration
    # def eventbrite_client
    #   OAuth2::Client.new(
    #     ENV['EVENTBRITE_CLIENT_ID'],
    #     ENV['EVENTBRITE_CLIENT_SECRET'],
    #     site: ENV['EVENTBRITE_URL']
    #   )
    # end

    # def eventbrite_access_token
    #   OAuth2::AccessToken.new(
    #     eventbrite_client,
    #     eventbrite_token,
    #     refresh_token: eventbrite_refresh_token,
    #     expires_at: eventbrite_token_expires_at.to_i
    #   )
    # end

    # def refresh_eventbrite_token!
    #   return unless eventbrite_token_expires_at < Time.current

    #   new_token = eventbrite_access_token.refresh!

    #   update(
    #     eventbrite_token: new_token.token,
    #     eventbrite_refresh_token: new_token.refresh_token,
    #     eventbrite_token_expires_at: Time.at(new_token.expires_at)
    #   )
    # end

    # def fetch_eventbrite_events
    #   refresh_eventbrite_token!

    #   response = eventbrite_access_token.get('/v3/users/me/owned_events/')
    #   JSON.parse(response.body)['events']
    # end

    private

    def from_omniauth_events360(auth)
      user_info = {
        uid: auth.uid.to_s,
        provider: auth.provider.to_s,
        email: auth.info.email,
        name: auth.info.name
      }

      user = User.find_by(uid: user_info[:uid], provider: user_info[:provider])

      if user.present?
        user.update(user_info)
        user
      else
        User.create(user_info)
      end
    end

    def from_omniauth_eventbrite(auth, current_user)
      user = current_user
      # TODO: Store/Update user info (eventbrite_uid, token, refersh_token, token_exp)
      # if @user.present?
      #   user.update(
      #     eventbrite_uid: auth.uid,
      #     eventbrite_token: auth.credentials.token,
      #     eventbrite_refresh_token: auth.credentials.refresh_token,
      #     eventbrite_token_expires_at: Time.at(auth.credentials.expires_at)
      #   )
      # end
    end
  end
end
