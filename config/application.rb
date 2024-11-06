# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Fashionxt002
module Fashionxt002
  # Defines the configuration for the Rails application.
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Adds the Warden middleware to the application's middleware stack.
    config.middleware.use Warden::Manager

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)

    # Autoloads the lib/constants directory in development mode.
    config.autoload_paths << Rails.root.join('lib', 'constants')

    # Eager loads the lib/constants directory in production mode.
    config.eager_load_paths << Rails.root.join('lib', 'constants')
  end
end
