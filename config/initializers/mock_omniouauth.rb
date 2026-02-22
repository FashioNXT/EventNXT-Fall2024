require Rails.root.join('lib/omniauth/strategies/cast_nxt.rb')
require Rails.root.join('lib/omniauth/strategies/pla_nxt.rb')
require Rails.root.join('lib/omniauth/strategies/event_nxt.rb')

if Rails.env.development?
  OmniAuth.config.test_mode = true

  # Using specific providers for mock authentication
  OmniAuth.config.mock_auth[:castnxt] = OmniAuth::AuthHash.new({
    provider: 'castnxt',
    uid: 'castnxt_user_uid',
    info: {
      email: 'castnxt_user@example.com',
      name: 'CastNXT User'
    }
  })

  OmniAuth.config.mock_auth[:planxt] = OmniAuth::AuthHash.new({
    provider: 'planxt',
    uid: 'planxt_user_uid',
    info: {
      email: 'planxt_user@example.com',
      name: 'PlaNXT User'
    }
  })

  OmniAuth.config.mock_auth[:eventnxt] = OmniAuth::AuthHash.new({
    provider: 'eventnxt',
    uid: 'eventnxt_user_uid',
    info: {
      email: 'eventnxt_user@example.com',
      name: 'EventNXT User'
    }
  })

  # Add more users as needed...

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :castnxt, OmniAuth::Strategies::CastNxt
    provider :planxt, OmniAuth::Strategies::PlaNxt
    provider :eventnxt, OmniAuth::Strategies::EventNxt
  end
end
