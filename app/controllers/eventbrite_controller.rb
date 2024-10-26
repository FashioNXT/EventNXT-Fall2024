# Eventbrite Events Controller
class EventbriteEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_eventbrite_connected

  def index
    # Fetch events from Eventbrite API
    eventbrite = EventbriteApi.new(current_user)
    response = eventbrite.user_owned_events

    if response['events']
      @ext_events = response['events']
    else
      @ext_events = []
      flash.now[:alert] = 'Could not fetch events from Eventbrite.'
    end
  end

  private

  def ensure_eventbrite_connected
    return if current_user.eventbrite_token.present?

    redirect_to user_eventbrite_omniauth_authorize_path, alert: 'Please connect your Eventbrite account.'
  end
end
