# frozen_string_literal: true

# spec/controllers/referrals_controller_spec.rb
require 'rails_helper'

RSpec.describe ReferralsController, type: :controller do
  let(:user) { create(:user) }
  before do
    sign_in user
  end

  describe 'create method for referral after the friend email sent' do
    let(:event) { create(:event, user:) }
    let(:seat) { create(:seat, event:) }
    let(:guest) { create(:guest, event:) }
    let(:friend_emails) { 'aaaaaaa@aaaaaaa.???' }
    let(:ref_code) { guest.id }
    it 'then we will have a new referral created' do
      post :referral_creation,
        params: { random_code: guest.rsvp_link,
        friend_emails: 'aaaaaaa@aaaaaaa.???' }

      expect(Referral.last.referred).to eq('aaaaaaa@aaaaaaa.???')
    end
  end

  describe 'update method for referral after we have a referral' do
    let(:event) { create(:event, user:) }
    let(:seat) { create(:seat, event:) }
    let(:guest) { create(:guest, event:) }
    it 'then we will have reward updated' do
      the_referral_parametrization = {
        email: guest.email,
        name: "#{guest.first_name} #{guest.last_name}",
        referred: 'aaaaaaa@aaaaaaa.aaa',
        status: true,
        tickets: 3,
        amount: 150,
        reward_method: 'reward/ticket',
        reward_input: 0,
        reward_value: 0,
        guest_id: guest.id,
        event_id: event.id,
        ref_code: guest.id
      }
      @referral = Referral.create(the_referral_parametrization)
      @referral.save

      the_referral_parametrization_updated = @referral.attributes.merge(reward_input: 10)

      put :update, params: {
        event_id: event.id,
        id: @referral.id,
        email: guest.email,
        name: "#{guest.first_name} #{guest.last_name}",
        referred: 'aaaaaaa@aaaaaaa.aaa',
        status: true,
        tickets: 3,
        amount: 150,
        reward_method: 'reward/ticket',
        reward_input: 10,
        guest_id: guest.id,
        ref_code: guest.id,
        referral: the_referral_parametrization_updated
      }
      @referral.reload
      expect(@referral.reward_value).to eq(30)

      put :update, params: {
        event_id: event.id,
        id: @referral.id,
        email: guest.email,
        name: "#{guest.first_name} #{guest.last_name}",
        referred: 'aaaaaaa@aaaaaaa.aaa',
        status: true,
        tickets: 3,
        amount: 150,
        reward_method: 'reward percentage %',
        reward_input: 10,
        guest_id: guest.id,
        ref_code: guest.id,
        referral: the_referral_parametrization_updated
      }
      @referral.reload
      expect(@referral.reward_value).to eq(15)
    end
  end
end
