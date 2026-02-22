# frozen_string_literal: true

require 'omniauth-oauth2'
require Rails.root.join('lib', 'constants')

module OmniAuth
  module Strategies
    # Custom OAuth Strategy for EventNXT
    class EventNxt < OmniAuth::Strategies::OAuth2
      Rails.logger.info 'Loading OmniAuth::Strategies::EventNxt'
      option :name, Constants::EventNXT::NAME

      option :client_options, {
        site: Constants::EventNXT::URL,
        authorize_url: "#{Constants::EventNXT::URL}/oauth/authorize",
        token_url: "#{Constants::EventNXT::URL}/oauth/token",
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
      end
    end
  end
end
