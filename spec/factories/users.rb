# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :user do
    uid { Faker::Number.unique.number(digits: 6).to_s }
    provider { Constants::Events360::NAME }
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
  end

  # Define multiple factories for the same model
  trait Constants::Events360::SYM do
    provider { Constants::Events360::NAME }
  end

  trait Constants::Eventbrite::SYM do
    eventbrite_uid { Faker::Number.unique.number(digits: 12).to_s }
    eventbrite_token { 'fake-token' }
  end
end
