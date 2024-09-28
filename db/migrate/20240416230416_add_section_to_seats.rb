class AddSectionToSeats < ActiveRecord::Migration[7.0]
  def change
    add_column :seats, :section, :string
  end
end
