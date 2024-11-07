# frozen_string_literal: true

# Load and launch SimpleCov at the very top
require 'simplecov'
SimpleCov.start 'rails'

# Set Rails environment to 'test' before loading Rails
ENV['RAILS_ENV'] ||= 'test'

# Load the Rails environment
require_relative '../config/environment'

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

# Set a default for APP_URL if in test environment
ENV['APP_URL'] ||= 'http://localhost:3000' if Rails.env.test?

# Load RSpec and other libraries
require 'rspec/rails'
require 'active_job'
require 'devise'

# Configure ActiveJob to use :test adapter
ActiveJob::Base.queue_adapter = :test

# Requires supporting ruby files in spec/support and its subdirectories.
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations before tests run
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

# Configure Shoulda Matchers for RSpec
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
