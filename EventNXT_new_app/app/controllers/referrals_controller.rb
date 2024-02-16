class ReferralsController < ApplicationController
  def refer_friend
    @event = Event.find(params[:id])
    @guest = Guest.find_by(rsvp_token: params[:token])
  end
end
