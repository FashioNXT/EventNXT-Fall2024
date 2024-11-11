# frozen_string_literal: true

# Create Seats Class
class CreateSeats < ActiveRecord::Migration[7.0]
  def change
    create_table :seats do |t|
      t.string :category
      t.integer :total_count
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end
  end
end
