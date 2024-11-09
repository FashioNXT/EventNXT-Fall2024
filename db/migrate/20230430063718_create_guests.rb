# frozen_string_literal: true

class CreateGuests < ActiveRecord::Migration[7.0]
  def change
    create_table :guests do |t|
      t.string :first_name
      t.string :last_name
      t.string :affiliation
      t.string :category
      t.integer :alloted_seats
      t.integer :commited_seats
      t.integer :guest_commited
      t.boolean :status
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end
  end
end
