# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :event do
    title { 'Sample Event' }
    description { 'A description of the event' }
    ticket_source { Constants::TicketSales::Source::SPREADSHEET }
    
    trait :with_external_event_id do
      ticket_source { Constants::TicketSales::Source::EVENTBRITE }
      external_event_id { Faker::Number.unique.number(digits: 12).to_s }
    end
    association :user, factory: :user
  end
end
