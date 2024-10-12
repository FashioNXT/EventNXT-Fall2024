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

    # Define multiple factories for the same model
    trait :guest1 do
      first_name { 'Test Guestd 1' }
      last_name { 'Fake' }
      email { 'testguest1@sample.com' }
    end

    trait :guest2 do
      first_name { 'Test Guest 2' }
      last_name { 'Fake' }
      email { 'testguest2@sample.com' }
    end

    trait :guest3 do
      first_name { 'Test Guest 3' }
      last_name { 'Fake' }
      email { 'testguest3@sample.com' }
    end
  end
end
