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
    self.validate_category_section(ticket_sales)
  end

  def validate_category_section(ticket_sales)
    seats = @event.seats

    ticket_sales.each do |sale|
      category = sale[FIELDS::CATEGORY]
      section = sale[FIELDS::SECTION]

      if seats.find_by(category:, section:).nil?
        sale[FIELDS::FLAGS] ||= Set.new
        sale[FIELDS::FLAGS].add(FLAGS::INVALID_CATEGORY_SECTION)
      end
    end
  end
end
