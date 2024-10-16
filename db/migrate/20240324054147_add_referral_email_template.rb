# frozen_string_literal: true

class AddReferralEmailTemplate < ActiveRecord::Migration[7.0]
  def change
    EmailTemplate.create!(
      name: 'Referral Invitation',
      subject: 'Invite Your Friends!',
      body: 'Hello, <br>Invite your friends using this link: <a href="PLACEHOLDER_LINK">Refer a friend</a>.<br>Best,'
    )
  end
end
