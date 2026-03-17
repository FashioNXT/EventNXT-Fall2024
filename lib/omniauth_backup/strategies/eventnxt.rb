# frozen_string_literal: true

require 'omniauth-oauth2'
require Rails.root.join('lib', 'constants')

module OmniAuth
  module Strategies
    # Custom OAuth Strategy for EventNXT
    class EventNXT < OmniAuth::Strategies::OAuth2
      Rails.logger.info 'Loading OmniAuth::Strategies::EventNXT'
      option :name, Constants::EVENTS360::NAME

      option :client_options, {
        site: Constants::EVENTS360::URL,
        authorize_url: "#{Constants::EVENTS360::URL}/oauth/authorize",
        token_url: "#{Constants::EVENTS360::URL}/oauth/token",
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
