class CreateTicketSales < ActiveRecord::Migration[7.0]
  def change
    create_table :ticket_sales do |t|
      t.string :first_name
      t.string :last_name
      t.string :email, null: false, unique: true
      t.string :affiliation
      t.string :category, null: false
      t.string :section, null: false
      t.integer :tickets, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end

    # Add unique index on email
    add_index :ticket_sales, "LOWER(email)", unique: true, name: 'index_ticket_sales_on_lower_email'
  end
end
