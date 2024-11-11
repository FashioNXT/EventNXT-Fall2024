# frozen_string_literal: true

# AddColumnNameToUsers
class AddColumnNameToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :name, :string
  end
end
