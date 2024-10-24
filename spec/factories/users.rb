# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :user do
    uid { Faker::Number.unique.number(digits: 6).to_s }
    provider { 'fake-provider' }
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
  end

  # Define multiple factories for the same model
  trait Constants::Events360::SYM do
    provider { Constants::Events360::NAME }
  end

  trait :with_invalid_email do
    email { 'invalid-email' }
  end
end
