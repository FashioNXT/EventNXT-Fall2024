# frozen_string_literal: true

class ReferralsController < ApplicationController
  before_action :authenticate_user!, only: %i[edit update]
  before_action :set_event, only: %i[edit update]
  before_action :set_referral, only: %i[edit update]

  def new
    random_code = params[:random_code]
    @guest = Guest.find_by(rsvp_link: random_code)
    return if @guest

    render plain: 'link not working'
  end

  def referral_creation
    friend_email = params[:friend_email]
    # ref_code = params[:ref_code]
    random_code = params[:random_code]
    @guest = Guest.find_by(rsvp_link: random_code)
    if @guest
      @referral = Referral.find_or_create_by(event_id: @guest.event_id, guest_id: @guest.id, email: @guest.email,
        name: "#{@guest.first_name} #{@guest.last_name}", referred: friend_email, ref_code: @guest.id)
      @referral.save
      UserMailer.referral_confirmation(friend_email).deliver_now

      respond_to do |format|
        format.html { head :no_content }
        format.js
      end
    else
      redirect_to root_path
    end
  end

  # GET /referrals/1/edit
  def edit; end

  # PATCH/PUT /referrals/1 or /referrals/1.json
  def update
    #  @referral = Referral.find(params[:id])
    if params[:reward_method] == 'reward/ticket'
      # the_referral_parametrization = {
      #   email: @referral.email,
      #   name: @referral.name,
      #   referred: @referral.referred,
      #   status: @referral.status,
      #   tickets: @referral.tickets,
      #   amount: @referral.amount,
      #   reward_method: 'reward/ticket',
      #   reward_input: params[:reward_input],
      #   reward_value: params[:reward_input] * tickets,
      #   guest_id: @guest.id,
      #   ref_code: @guest.id
      #  }
      @referral.update(referral_params)
      @referral.update_attribute(:reward_value,
        referral_params[:reward_input].to_f * @referral.tickets)
    elsif params[:reward_method] == 'reward percentage %'
      # the_referral_parametrization = {
      #   email: @referral.email,
      #   name: @referral.name,
      #   referred: @referral.referred,
      #   status: @referral.status,
      #   tickets: @referral.tickets,
      #   amount: @referral.amount,
      #   reward_method: 'reward percentage %',
      #   reward_input: params[:reward_input],
      #   reward_value: ((@referral.amount) * params[:reward_input]) / 100,
      #   guest_id: @guest.id,
      #   ref_code: @guest.id
      #  }
      @referral.update(referral_params)
      @referral.update_attribute(:reward_value,
        (@referral.amount * referral_params[:reward_input].to_f) / 100)
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_referral
    @referral = @event.referrals.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def referral_params
    params.require(:referral).permit(:event_id, :guest_id, :email, :name, :referred, :status, :tickets, :amount,
      :reward_method, :reward_input, :ref_code, :reward_value)
  end
end
