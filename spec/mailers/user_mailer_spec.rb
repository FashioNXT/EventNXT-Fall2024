# spec/mailers/user_mailer_spec.rb
require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'referral_confirmation' do
    let(:mail) { UserMailer.referral_confirmation('friend@example.com') }

    it 'renders the headers' do
      expect(mail.subject).to eq('Confirm Your Ticket Purchase')
      expect(mail.to).to eq(['friend@example.com'])
      expect(mail.from).to eq(['notifications@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('http://localhost:3000/tickets/new')
    end
  end
end
