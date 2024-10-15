# Helper Functions for TicketSales Controller and Views
module TicketSalesHelper
  def ticket_sale_dom_id(ticket_sale)
    "ticket-sale-#{ticket_sale.id}"
  end

  def ticket_sale_form_dom_id
    'ticket-sale-form'
  end
end
