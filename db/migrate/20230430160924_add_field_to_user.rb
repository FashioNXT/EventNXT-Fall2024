# <!--===================-->
# <!--these fields are added to implement third-party authentication-->

class AddFieldToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
  end
end
