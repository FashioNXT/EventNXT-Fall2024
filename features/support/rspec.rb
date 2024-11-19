require 'rspec/mocks'

# Including RSpec Mocks manually
World(RSpec::Mocks::ExampleMethods)

# Ensuring RSpec Mocks are initialized and reset after each scenario
Before do
  RSpec::Mocks.setup
end

After do
  RSpec::Mocks.verify
  RSpec::Mocks.teardown
end