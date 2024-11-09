# frozen_string_literal: true

class AddRsvpLinkToGuests < ActiveRecord::Migration[7.0]
  def change
    add_column :guests, :rsvp_link, :string
  end
end
