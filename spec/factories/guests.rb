# frozen_string_literal: true

# spec/factories/guests.rb
FactoryBot.define do
  factory :guest do
    first_name { 'John' }
    last_name { 'Doe' }
    email { 'johndoe@example.com' }
    affiliation { 'Friend' }
    category { 'Adult' }
    alloted_seats { 10 }
    commited_seats { 10 }
    guest_commited { 1 }
    rsvp_link { '6db1b189f44b' }
    status { 'Confirmed' }
    section { 1 }
    association :event, factory: :event
    # Add any other attributes as needed
  end
end
