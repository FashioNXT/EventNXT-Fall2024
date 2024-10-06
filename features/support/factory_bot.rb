# features/support/factory_bot.rb
World(FactoryBot::Syntax::Methods)

Before do
  FactoryBot.reload
end
