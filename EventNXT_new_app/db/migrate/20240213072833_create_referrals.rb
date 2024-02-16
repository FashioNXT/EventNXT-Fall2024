class CreateReferrals < ActiveRecord::Migration[7.0]
  def change
    create_table :referrals do |t|
      t.integer :referrer_id
      t.string :referred_email
      t.string :status
      t.integer :event_id

      t.timestamps
    end
  end
end
