class AddEventbriteFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :eventbrite_uid, :string
    add_column :users, :eventbrite_token, :string
  end
end
