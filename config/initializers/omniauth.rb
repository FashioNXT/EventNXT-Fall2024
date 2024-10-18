# frozen_string_literal: true

require Rails.root.join('lib/omniauth/strategies/events360')
require Rails.root.join('lib/omniauth/strategies/eventbrite')

# OmniAuth.config.add_camelization 'events360', 'Events360'

# Rails.application.config.middleware.use OmniAuth::Builder do
#   provider :developer if Rails.env.development?
#   provider :events360,
#     ENV['NXT_APP_ID'],
#     ENV['NXT_APP_SECRET'],
#     scope: 'public',
#     strategy_class: OmniAuth::Strategies::Events360
# end
