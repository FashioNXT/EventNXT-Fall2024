OmniAuth.config.test_mode = true

# Mock OAuth data for events360 provider
OmniAuth.config.mock_auth[:events360] = OmniAuth::AuthHash.new({
  provider: 'events360',
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
  OmniAuth.config.mock_auth[:events360] = :invalid_credentials
end