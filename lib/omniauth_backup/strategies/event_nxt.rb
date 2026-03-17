# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    # Custom OAuth Strategy for EventNXT
    class EventNxt < OmniAuth::Strategies::OAuth2
      # We use direct strings here to prevent boot-time errors before constants load
      option :name, "eventnxt"

      option :client_options, {
        site: "https://eventnxt.com",
        authorize_url: "https://eventnxt.com/oauth/authorize",
        token_url: "https://eventnxt.com/oauth/token",
        scope: 'public'
      }

      uid do
        raw_info['id']
      end

      info do
        {
          name: raw_info['name'],
          email: raw_info['email']
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/api/user').parsed
      rescue StandardError
        {}
      end
    end
  end
end