require 'faker'
FactoryBot.define do
  factory :seat do
    category { Faker::Lorem.word }
    total_count { Faker::Number.between(from: 1, to: 100) }
    section { Faker::Number.between(from: 1, to: 20) }
    event # Associate the seat with an event using the factory definition
  end
end
