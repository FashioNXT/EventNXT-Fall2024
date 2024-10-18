require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    # Custom OAuth Strategy for Eventbrite
    class Eventbrite < OmniAuth::Strategies::OAuth2
      option :name, 'eventbrite'

      option :client_options, {
        site: ENV['EVENTBRITE_URL'],
        authorize_url: "#{ENV['EVENTBRITE_URL']}/oauth/authorize",
        token_url: "#{ENV['EVENTBRITE_URL']}/oauth/token"
      }

      uid { raw_info['id'] }

      info do
        {
          name: raw_info['name'],
          email: raw_info['email']
          # Add other fields as needed
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/v3/users/me/').parsed
      end
    end
  end
end
