# In Rails controller and feature tests (RSpec), you can use Devise::Test::IntegrationHelpers
# because they are designed to work with Rails' test framework directly.
# However, Cucumber operates in a slightly different context, and since Devise uses Warden under the hood,
# it's better to directly use Warden’s test helpers in the Cucumber environment.

# Ensure Warden test helpers are available
World Warden::Test::Helpers

# Include Warden test helpers for Cucumber
Warden.test_mode!

Before('@pre_authenticated') do
  @user = create(:user, Constants::Events360::SYM)
  login_as(@user, scope: :user)
end

# Reset Warden after each scenario to prevent leakage between tests
After do
  Warden.test_reset!
end
