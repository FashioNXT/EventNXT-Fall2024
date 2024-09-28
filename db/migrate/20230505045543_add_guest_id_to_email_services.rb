class AddGuestIdToEmailServices < ActiveRecord::Migration[7.0]
  def change
    # add_reference :email_services, :guest, null: false, foreign_key: true
    add_reference :email_services, :guest, null: true, foreign_key: true
  end
end
