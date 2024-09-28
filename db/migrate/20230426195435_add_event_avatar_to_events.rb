class AddEventAvatarToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :event_avatar, :string
  end
end
