class AddBoxOfficeToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :event_box_office, :string
  end
end
