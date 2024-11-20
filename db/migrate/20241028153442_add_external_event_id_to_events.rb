class AddExternalEventIdToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :external_event_id, :string
  end
end
