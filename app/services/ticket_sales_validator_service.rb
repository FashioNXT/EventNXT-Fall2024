# Validate the data in @ticket_sales
class TicketSalesValidatorService
  TICKET_SALES = Constants::TicketSales
  FIELDS = TICKET_SALES::Field
  FLAGS = TICKET_SALES::Flags

  def initialize(event, ticket_sales: nil)
    @event = event
    @ticket_sales = ticket_sales
  end

  def validate(ticket_sales = @ticket_sales)
    return if ticket_sales.nil? || ticket_sales.empty?

    self.validate_category_section(ticket_sales)
  end

  def validate_category_section(ticket_sales = @ticket_sales)
    seats = @event.seats

    category_sections = seats.map { |s| [s[:category], s[:section]] }.to_set

    ticket_sales.each do |sale|
      category = sale[FIELDS::CATEGORY]
      section = sale[FIELDS::SECTION]

      unless category_sections.include?([category, section])
        sale[FIELDS::FLAGS] ||= Set.new
        sale[FIELDS::FLAGS].add(FLAGS::INVALID_CATEGORY_SECTION)
      end
    end
  end
end
