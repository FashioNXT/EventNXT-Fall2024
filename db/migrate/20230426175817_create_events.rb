# frozen_string_literal: true

# Create Event
class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :title
      t.string :address
      t.string :description
      t.datetime :datetime
      t.datetime :last_modified

      t.timestamps
    end
  end
end
