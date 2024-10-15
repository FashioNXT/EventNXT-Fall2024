# Helper Functions for TicketSales Controller and Views
module TicketSalesHelper
  def ticket_sale_dom_id(ticket_sale)
    "ticket-sale-#{ticket_sale.id}"
  end

  def ticket_sale_form_dom_id
    'ticket-sale-form'
  end

  def ticket_sales_table_dom_id
    'ticket-sales-table'
  end

  def sortable(field, title = nil)
    title ||= field.titleize
    order = field == params[:sort_field] && params[:sort_order] == 'asc' ? 'desc' : 'asc'
    link_to title, event_ticket_sales_path(@event, sort_field: field, sort_order: order), data: { turbo_stream: true }
  end
end
