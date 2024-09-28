FactoryBot.define do
  factory :email_template do
    name { 'Sample Template' }
    body { 'This is the body of the email template.' }

    # Add any additional attributes as needed
  end
end
