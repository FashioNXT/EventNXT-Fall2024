class RemovePasswordColumnsFromUsers < ActiveRecord::Migration[7.0]
  def change
    # Remove the index first
    remove_index :users, name: 'index_users_on_reset_password_token'

    # Then remove the columns
    remove_column :users, :encrypted_password, :string, default: '', null: false
    remove_column :users, :reset_password_token, :string
    remove_column :users, :reset_password_sent_at, :datetime
    remove_column :users, :remember_created_at, :datetime
  end
end
