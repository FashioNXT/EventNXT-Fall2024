FactoryBot.define do
  factory :event do
    title { "Sample Event" }
    description { "A description of the event" }
    #date { Date.today }
    #location { "Sample Location" }
    trait :with_box_office do
      event_box_office { "Box Office Data" }
    end
    association :user, factory: :user
  end
end
