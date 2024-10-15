class CreateReferrals < ActiveRecord::Migration[7.0]
  def change
    create_table :referrals do |t|
      t.belongs_to :event
      t.belongs_to :guest
      t.string :email, null: false
      t.string :name, null: false
      t.string :referred, null: false

      t.string :status, default: false
      t.integer :tickets, default: 0
      t.float :amount, default: 0

      t.string :reward_method, default: 'reward/ticket'
      t.float :reward_input, default: 0
      t.float :reward_value, default: 0

      t.integer :ref_code, null: false

      t.timestamps
    end
  end
end
