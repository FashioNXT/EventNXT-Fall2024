require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class EVENTS360 < OmniAuth::Strategies::OAuth2
      # This identifies the "Parent" to the "Child"
      option :name, 'events360'

      # This tells the child app where to find the parent portal locally
      option :client_options, {
        site: "http://localhost:3000",
        authorize_url: "http://localhost:3000/oauth/authorize",
        token_url: "http://localhost:3000/oauth/token"
      }

      def raw_info
        @raw_info ||= access_token.get('/api/v1/me').parsed
      end
    end
  end
end