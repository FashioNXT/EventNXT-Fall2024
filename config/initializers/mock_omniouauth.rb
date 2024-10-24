if Rails.env.development?
  OmniAuth.config.test_mode = true

  OmniAuth.config.mock_auth[:events360_user1] = OmniAuth::AuthHash.new({
    provider: 'events360',
    uid: 'user1_uid',
    info: {
      email: 'user1@example.com',
      name: 'User One'
    }
  })

  OmniAuth.config.mock_auth[:events360_user2] = OmniAuth::AuthHash.new({
    provider: 'events360',
    uid: 'user2_uid',
    info: {
      email: 'user2@example.com',
      name: 'User Two'
    }
  })

  OmniAuth.config.mock_auth[:events360_user3] = OmniAuth::AuthHash.new({
    provider: 'events360',
    uid: 'user3_uid',
    info: {
      email: 'user3@example.com',
      name: 'User Three'
    }
  })

  # Add more users as needed...

  OmniAuth.config.logger = Rails.logger

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :events360, setup: lambda { |env|
      request = Rack::Request.new(env)

      # Store the 'user' parameter in the session during the request phase
      env['rack.session'][:user] = request.params['user'] if request.params['user'].present?
    }
  end
end
