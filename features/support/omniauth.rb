OmniAuth.config.test_mode = true

# Mock OAuth data for events360 provider
OmniAuth.config.mock_auth[Constants::Events360::SYM] = OmniAuth::AuthHash.new({
  provider: Constants::Events360::NAME,
  uid: '123456',
  info: {
    email: 'user@example.com',
    name: 'John Doe'
  }
})

Before('@omniauth_test') do
  OmniAuth.config.test_mode = true
end

Before('@omniauth_test_failure') do
  OmniAuth.config.test_mode = true
  # Simulate OAuth failure
  OmniAuth.config.mock_auth[Constants::Events360::SYM] = :invalid_credentials
end
