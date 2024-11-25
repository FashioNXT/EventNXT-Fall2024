# frozen_string_literal: true

# AddEmailToGuests
class AddEmailToGuests < ActiveRecord::Migration[7.0]
  def change
    add_column :guests, :email, :string
  end
end
