# Get ticket sales data from spreadsheet
class TicketSalesSpreadsheetService
  def initialize(event, spreadsheet: nil)
    @event = event
    @spreadsheet = spreadsheet || @event.event_box_office
  end

  def import_data(spreadsheet = @spreadsheet)
    @spreadsheet ||= spreadsheet

    spreadsheet_ticket_sales = []

    if @spreadsheet.present?
      event_box_office_file = @event.event_box_office.current_path
      event_box_office_xlsx = Roo::Spreadsheet.open(event_box_office_file)

      headers = event_box_office_xlsx.row(1)
      email_index = headers.index('Email')
      tickets_index = headers.index('Tickets')
      amount_index = headers.index('Amount')
      category_index = headers.index('Category')
      section_index = headers.index('Section')

      event_box_office_xlsx.each_row_streaming(offset: 1) do |row|
        spreadsheet_ticket_sales << {
          email: row[email_index]&.value,
          tickets: row[tickets_index]&.value.to_i,
          cost: row[amount_index]&.value.to_f,
          category: row[category_index]&.value,
          section: row[section_index]&.value
        }
      end
    end

    spreadsheet_ticket_sales
  end
end
