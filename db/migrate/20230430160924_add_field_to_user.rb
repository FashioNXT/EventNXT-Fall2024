# frozen_string_literal: true

# <!--===================-->
# <!--these fields are added to implement third-party authentication-->

# AddFieldToUser
class AddFieldToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
  end
end
