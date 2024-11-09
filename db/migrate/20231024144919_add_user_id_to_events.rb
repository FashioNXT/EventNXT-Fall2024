# frozen_string_literal: true

class AddUserIdToEvents < ActiveRecord::Migration[7.0]
  def change
    add_reference :events, :user, foreign_key: true, default: 1 # Set default user_id to 1 or any default user ID
    change_column_default :events, :user_id, 1
  end
end
