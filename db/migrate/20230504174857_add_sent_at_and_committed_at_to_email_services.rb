# frozen_string_literal: true

class AddSentAtAndCommittedAtToEmailServices < ActiveRecord::Migration[7.0]
  def change
    add_column :email_services, :sent_at, :datetime
    add_column :email_services, :committed_at, :datetime
  end
end
