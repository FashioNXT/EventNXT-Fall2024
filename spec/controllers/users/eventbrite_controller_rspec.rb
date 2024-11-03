require 'rails_helper'

RSpec.describe Users::EventbriteController, type: :controller do
  describe 'POST #disconnect' do
    let(:user) { nil }
    let(:config) { instance_double(TicketVendor::Config) }
    let(:service) { instance_double(TicketVendor::EventbriteHandlerService) }

    before do
      allow(TicketVendor::Config).to receive(:new).and_return(config)
      allow(TicketVendor::EventbriteHandlerService).to receive(:new)
        .with(user, config)
        .and_return(service)
      allow(service).to receive(:disconnect)
    end

    it 'calls disconnect on the service and redirects to events path' do
      post :disconnect

      expect(service).to have_received(:disconnect)
      expect(response).to redirect_to(events_path)
    end
  end
end
