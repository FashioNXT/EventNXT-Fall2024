# Rails initializes files in the config/initializers/ directory in alphabetical order.
# To ensure your custom strategies are loaded before Devise initializes OmniAuth,
# name the initializer with a prefix that loads it early.

begin
  Rails.logger.info 'Loading custom OmniAuth strategies: Eventbrite and Events360'
  require_dependency Rails.root.join('lib', 'omniauth', 'strategies', 'events360.rb')
rescue StandardError => e
  Rails.logger.error "Error loading OmniAuth strategies: #{e.message}"
end

# require 'omniauth/strategies/eventbrite'
# require 'omniauth/strategies/events360'
