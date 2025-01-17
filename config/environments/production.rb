# frozen_string_literal: true

require 'active_support/core_ext/integer/time'
require 'semantic_logger'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true
  # only allow certain domain to access this app.
  config.hosts << URI.parse(ENV['APP_URL'] || 'http://localhost').host
  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  # config.log_level = ENV['RAILS_LOG_LEVEL'] || :info

  # # Use default logging formatter so that PID and timestamp are not suppressed.
  # config.log_formatter = ::Logger::Formatter.new

  # # Use a different logger for distributed setups.
  # # require "syslog/logger"
  # # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new "app-name")

  # if ENV['RAILS_LOG_TO_STDOUT'].present?
  #   logger           = ActiveSupport::Logger.new($stdout)
  #   logger.formatter = config.log_formatter
  #   config.logger    = ActiveSupport::TaggedLogging.new(logger)
  # end

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Set the log level and formatter for production
  SemanticLogger.default_level = ENV['RAILS_LOG_LEVEL'] || :info # Set to :warn or :error for quieter logging
  SemanticLogger.add_appender(io: $stdout, formatter: :color) # Heroku-compatible, structured JSON logs
  # Optional: Add an additional appender for file-based logging (if not on Heroku)
  # SemanticLogger.add_appender(file_name: "log/production.log", formatter: :color)

  # Assign SemanticLogger as Rails logger
  Rails.logger = SemanticLogger['Rails']

  # Ref: https://github.com/reidmorrison/rails_semantic_logger/issues/29
  formatter = ActiveSupport::Logger::SimpleFormatter.new
  formatter.extend ActiveSupport::TaggedLogging::Formatter
  Rails.logger.formatter = formatter

  # Prepend all log lines with the following tags.
  # config.log_tags = [:request_id]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "fashionxt_002_production"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false
  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  config.action_mailer.raise_delivery_errors = true

  # Configure ActionMailer for email delivery using SendGrid
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    user_name: ENV['SENDGRID_USERNAME'],
    password: ENV['SENDGRID_PASSWORD'],
    domain: ENV['APP_URL'], # Ensure this matches your Heroku app URL or custom domain
    address: 'smtp.sendgrid.net',
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true
  }

  # Default URL options for ActionMailer
  config.action_mailer.default_url_options = { host: ENV['APP_URL'], protocol: 'https' }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
