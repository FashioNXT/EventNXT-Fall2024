# frozen_string_literal: true

# AddSectionToGuests
class AddSectionToGuests < ActiveRecord::Migration[7.0]
  def change
    add_column :guests, :section, :string
  end
end
