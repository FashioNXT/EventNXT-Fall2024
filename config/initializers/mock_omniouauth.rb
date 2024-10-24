if Rails.env.development?
  OmniAuth.config.test_mode = true

  OmniAuth.config.mock_auth[Constants::Events360::Mock::USER1] = OmniAuth::AuthHash.new({
    provider: Constants::Events360::NAME,
    uid: 'user1_uid',
    info: {
      email: 'user1@example.com',
      name: 'User One'
    }
  })

  OmniAuth.config.mock_auth[Constants::Events360::Mock::USER2] = OmniAuth::AuthHash.new({
    provider: Constants::Events360::NAME,
    uid: 'user2_uid',
    info: {
      email: 'user2@example.com',
      name: 'User Two'
    }
  })

  OmniAuth.config.mock_auth[Constants::Events360::Mock::USER3] = OmniAuth::AuthHash.new({
    provider: Constants::Events360::NAME,
    uid: 'user3_uid',
    info: {
      email: 'user3@example.com',
      name: 'User Three'
    }
  })

  # Add more users as needed...

  OmniAuth.config.logger = Rails.logger

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider Constants::Events360::SYM, setup: lambda { |env|
      request = Rack::Request.new(env)

      # Store the 'user' parameter in the session during the request phase
      env['rack.session'][:user] = request.params['user'] if request.params['user'].present?
    }
  end
end
