if Rails.env.development?
  OmniAuth.config.test_mode = true

  # Using generic names to avoid confusion and potential branding issues.
  # Consider using environment variables for configuration.
  provider_name = 'ExternalAuthProvider'

  OmniAuth.config.mock_auth[:mock_user1] = OmniAuth::AuthHash.new({
    provider: provider_name,
    uid: 'mock_user1_uid',
    info: {
      email: 'mock_user1@example.com',
      name: 'Mock User One'
    }
  })

  OmniAuth.config.mock_auth[:mock_user2] = OmniAuth::AuthHash.new({
    provider: provider_name,
    uid: 'mock_user2_uid',
    info: {
      email: 'mock_user2@example.com',
      name: 'Mock User Two'
    }
  })

  OmniAuth.config.mock_auth[:mock_user3] = OmniAuth::AuthHash.new({
    provider: provider_name,
    uid: 'mock_user3_uid',
    info: {
      email: 'mock_user3@example.com',
      name: 'Mock User Three'
    }
  })

  # Add more users as needed...

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider provider_name.to_sym, setup: lambda { |env|
      request = Rack::Request.new(env)

      # Store the 'user' parameter in the session during the request phase
      env['rack.session'][:user] = request.params['user'] if request.params['user'].present?
    }
  end
end
