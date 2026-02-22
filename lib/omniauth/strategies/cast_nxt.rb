require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class CastNxt < OmniAuth::Strategies::OAuth2
      option :name, "castnxt"
      option :client_options, {
        site: "https://castnxt.com",
        authorize_url: "/oauth/authorize",
        token_url: "/oauth/token"
      }
      uid { raw_info['id'] }
      info { { email: raw_info['email'], name: raw_info['name'] } }
      def raw_info
        @raw_info ||= access_token.get('/api/v1/me').parsed
      end
    end
  end
end
