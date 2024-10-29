class ReferralsController < ApplicationController
  before_action :authenticate_user!, only: %i[edit update]
  before_action :set_event, only: %i[edit update]
  before_action :set_referral, only: %i[edit update]

  def new
    random_code = params[:random_code]
    @guest = Guest.find_by(rsvp_link: random_code)

    unless @guest
      flash[:alert] = 'Invalid referral link.'
      redirect_to root_path
    end
  end

  def referral_creation
    friend_email = params[:friend_email]
    random_code = params[:random_code]
    @guest = Guest.find_by(rsvp_link: random_code)

    if @guest
      @referral = Referral.find_or_create_by(
        event_id: @guest.event_id,
        guest_id: @guest.id,
        email: @guest.email,
        name: "#{@guest.first_name} #{@guest.last_name}",
        referred: friend_email,
        ref_code: @guest.id
      )

      if @referral.persisted?
        UserMailer.referral_confirmation(friend_email).deliver_now
        respond_to do |format|
          format.html { redirect_to event_path(@guest.event), notice: 'Referral created and email sent!' }
          format.js
        end
      else
        flash[:error] = 'Referral could not be created.'
        redirect_to event_path(@guest.event)
      end
    else
      redirect_to root_path, alert: 'Guest not found or invalid link.'
    end
  end

  def edit; end

  def update
    if params[:reward_method] == 'reward/ticket'
      reward_value = referral_params[:reward_input].to_f * @referral.tickets
    elsif params[:reward_method] == 'reward percentage %'
      reward_value = (@referral.amount * referral_params[:reward_input].to_f) / 100
    end

    if @referral.update(referral_params.merge(reward_value: reward_value))
      redirect_to event_referrals_path(@event), notice: 'Referral updated successfully.'
    else
      render :edit, alert: 'Failed to update referral.'
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_referral
    @referral = @event.referrals.find(params[:id])
  end

  def referral_params
    params.require(:referral).permit(:event_id, :guest_id, :email, :name, :referred, :status, :tickets, :amount,
                                     :reward_method, :reward_input, :ref_code, :reward_value)
  end
end
