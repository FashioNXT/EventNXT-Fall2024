FactoryBot.define do
    factory :email_service do
        to { 'recipient@example.com' }
        subject { 'Email Subject' }
        body { 'Email Body' }
        event
        guest
    end
end