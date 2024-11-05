# frozen_string_literal: true

# AddEventRefToEmailServices
class AddEventRefToEmailServices < ActiveRecord::Migration[7.0]
  def change
    # add_reference :email_services, :event, null: false, foreign_key: true
    add_reference :email_services, :event, null: true, foreign_key: true
  end
end
