# frozen_string_literal: true

require 'omniauth-oauth2'
require Rails.root.join('lib', 'constants')

module OmniAuth
  module Strategies
    # Custom OAuth Strategy for Eventbrite
    class Eventbrite < OmniAuth::Strategies::OAuth2
      Rails.logger.info 'Loading OmniAuth::Strategies::Eventbrite'
      option :name, Constants::Eventbrite::NAME

      option :client_options, {
        site: Constants::Eventbrite::API_URL,
        authorize_url: "#{Constants::Eventbrite::URL}/oauth/authorize",
        token_url: "#{Constants::Eventbrite::URL}/oauth/token"
      }

      def build_access_token
        #  Ensure client_id and client_secret are added explicitly in the token exchange request body
        token_params = {
          client_id: options.client_id,
          client_secret: options.client_secret,
          code: request.params['code'],
          grant_type: 'authorization_code',
          redirect_uri: callback_url
        }
        # Call super with the overridden token parameters to add them to the token exchange request
        client.get_token(token_params, deep_symbolize(options.auth_token_params))
      rescue ::OAuth2::Error => e
        fail!(:invalid_credentials, e)
      end

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
