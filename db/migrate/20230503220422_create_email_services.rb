class CreateEmailServices < ActiveRecord::Migration[7.0]
  def change
    create_table :email_services do |t|
      t.string :to
      t.string :subject
      t.text :body

      t.timestamps
    end
  end
end
