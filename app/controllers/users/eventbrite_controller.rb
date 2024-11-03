module Users
  # Curretly only used for disconnect Eventbrite account
  class EventbriteController < ApplicationController
    def disconnect
      config = TicketVendor::Config.new
      service = TicketVendor::EventbriteHandlerService.new(current_user, config)
      service.disconnect
      redirect_to events_path
    end
  end
end
