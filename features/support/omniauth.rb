OmniAuth.config.test_mode = true

user = FactoryBot.build(:user, name: 'John Doe')

# Mock OAuth data for events360 provider
OmniAuth.config.mock_auth[Constants::Events360::SYM] = OmniAuth::AuthHash.new({
  provider: Constants::Events360::NAME,
  uid: user.uid,
  info: {
    email: user.email,
    name: user.name
  }
})

user = FactoryBot.build(:user, Constants::Eventbrite::SYM, name: 'John Doe')

# Mock OAuth data for eventbrite provider
OmniAuth.config.mock_auth[Constants::Eventbrite::SYM] = OmniAuth::AuthHash.new({
  provider: Constants::Eventbrite::NAME,
  uid: user.eventbrite_uid,
  info: {
    email: user.email,
    name: user.name
  },
  credentials: {
    token: user.eventbrite_token
  }
})


Before('@omniauth_test') do
  OmniAuth.config.test_mode = true
end

Before('@omniauth_except_crm') do
  @user = create(:user, Constants::Events360::SYM)
  login_as(@user, scope: :user)
  OmniAuth.config.test_mode = true
end

Before('@omniauth_test_failure') do
  OmniAuth.config.test_mode = true
  # Simulate OAuth failure
  OmniAuth.config.mock_auth[Constants::Events360::SYM] = :invalid_credentials
end
