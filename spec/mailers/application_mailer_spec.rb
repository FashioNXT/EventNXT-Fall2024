# require 'rails_helper'

# RSpec.describe ApplicationMailer, type: :mailer do
#   before do
#     # Configure ActionMailer to use test delivery method
#     ActionMailer::Base.delivery_method = :test
#     ActionMailer::Base.perform_deliveries = true
#     ActionMailer::Base.deliveries = []
#   end

#   describe "#send_email" do
#     let(:to) { "recipient@example.com" }
#     let(:subject) { "Test email subject" }
#     let(:body) { "Test email body" }

#     it "sends an email" do
#       mail = described_class.send_email(to, subject, body)

#       expect(mail.to).to eq([to])
#       expect(mail.subject).to eq(subject)
#       expect(mail.body).to include(body)
#       expect(ActionMailer::Base.deliveries.count).to eq(1)
#     end

#     it "uses the correct sender email" do
#       described_class.send_email(to, subject, body)
#       mail = ActionMailer::Base.deliveries.last

#       expect(mail.from).to eq(["fashionnxt@example.com"])
#     end
#   end
# end
#
RSpec.describe ApplicationMailer, type: :mailer do
  let(:event) { create(:event) }
  let(:guest) { create(:guest) }

  describe '#send_email' do
    let(:to) { 'recipient@example.com' }
    let(:subject) { 'Test Subject' }
    let(:body) { '<p>This is the email body.</p>' }
    let(:rsvp_url) { 'http://example.com/rsvp' }

    it 'sends an email with the correct attributes' do
      # Call the mailer method
      email = ApplicationMailer.send_email(to, subject, body, event, guest,
        rsvp_url)

      # puts email.body.to_s

      # Test the content of the sent email
      expect(email.subject).to eq(subject)
      expect(email.to).to eq([to])
      expect(email.from).to eq(['eventnxtapp@gmail.com']) # Check the default from address
      expect(email.body).to include(body)
      # expect(email.body).to include(rsvp_url)
    end
  end
end
