# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class CastNxt < OmniAuth::Strategies::OAuth2
      # The internal name for the provider
      option :name, "castnxt"

      option :client_options, {
        site: "https://castnxt.com",
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
      rescue StandardError
        {}
      end
    end
  end
end