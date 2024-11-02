class ChangeUserIndexes < ActiveRecord::Migration[7.0]
  def change
    # Remove the unique index on email
    remove_index :users, name: 'index_users_on_email'

    # Add a unique index on [:uid, :provider]
    add_index :users, %i[uid provider], unique: true
  end
end
