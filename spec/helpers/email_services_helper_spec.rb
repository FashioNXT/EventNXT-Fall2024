# spec/helpers/email_services_helper_spec.rb
require 'rails_helper'

RSpec.describe EmailServicesHelper, type: :helper do
  describe '#render_template_with_generic_placeholders' do
    let(:rsvp_email) { { subject: 'RSVP Invitation', body: 'Original Body' } }
    let(:referral_email) { { subject: 'Referral Invitation', body: 'Original Body' } }
    let(:other_email) { { subject: 'General Email', body: 'Original Body' } }

    it 'replaces placeholders with generic terms for RSVP template' do
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:read).and_return('<%= @event.title %> <%= @guest.first_name %> <%= @guest.last_name %>')

      result = helper.render_template_with_generic_placeholders(rsvp_email)
      expect(result).to include('EVENT')
      expect(result).to include('FIRST_NAME')
      expect(result).to include('LAST_NAME')
    end

    # it 'replaces placeholders with generic terms for Referral template' do
    #   allow(File).to receive(:exist?).and_return(true)
    #   allow(File).to receive(:read).and_return('<%= @event.description %> <%= @event.datetime %> <%= @event.address %>')

    #   result = helper.render_template_with_generic_placeholders(referral_email)
    #   expect(result).to include('EVENT_DESCRIPTION')
    #   expect(result).to include('EVENT_DATE')
    #   expect(result).to include('EVENT_ADDRESS')
    # end

    it 'renders body as is for other templates' do
      result = helper.render_template_with_generic_placeholders(other_email)
      expect(result).to eq('Original Body')
    end
  end
end
