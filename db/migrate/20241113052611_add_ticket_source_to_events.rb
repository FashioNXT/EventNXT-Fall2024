class AddTicketSourceToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :ticket_source, :string
  end
end
