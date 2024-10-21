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
    execute <<-SQL
      CREATE UNIQUE INDEX index_ticket_sales_on_event_id_and_lower_email
      ON ticket_sales (event_id, LOWER(email));
    SQL
  end
end
