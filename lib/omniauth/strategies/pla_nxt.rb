require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class PlaNxt < OmniAuth::Strategies::OAuth2
      # Custom OAuth Strategy for PlaNXT
      option :name, "planxt"

      option :client_options, {
        site: "https://planxt.com",
        authorize_url: "/oauth/authorize",
        token_url: "/oauth/token"
      }

      uid { raw_info['id'] }

      info do
        {
          email: raw_info['email'],
          name: raw_info['name']
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/api/v1/me').parsed
      end
    end
  end
end
