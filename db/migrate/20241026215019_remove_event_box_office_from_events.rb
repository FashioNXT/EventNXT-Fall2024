class RemoveEventBoxOfficeFromEvents < ActiveRecord::Migration[7.0]
  def change
    remove_column :events, :event_box_office, :string
  end
end
