# Controller for ticket sales
class TicketSalesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :set_ticket_sale, only: %i[edit update]
  respond_to :html, :json, :turbo_stream

  def index
    @ticket_sales = @event.ticket_sales.all
    respond_with @ticket_sales
  end

  def edit
    respond_with @ticket_sale
  end

  def update
    if @ticket_sale.update(ticket_sales_params)
      flash[:notice] = 'Ticket sale updated'
      respond_with @ticket_sale do |format|
        format.html { redirect_to event_path(@event) }
        # Turbo Stream logic is moved to update.turbo_stream.erb
        format.turbo_stream 
      end
    else
      respond_with @ticket_sale do |format|
        format.html { render :edit } # Re-render the edit form for HTML requests
        # Replace the form with the form with herror messages
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('ticket-sale-form', 
            partial: 'ticket_sales/form', locals: { ticket_sale: @ticket_sale }
          )
        end
      end
    end
  end

  def import_spreadsheet
    return redirect_to event_path(@event), alert: 'No file uploaded.' if params[:file].blank?

    spreadsheet_file = params[:file]
    result = TicketSale.import_spreadsheet(@event, spreadsheet_file)

    if result[:status] == false
      return redirect_to event_path(@event),
        alert: "Invalid file format or data: #{result[:err_msgs].join(', ')}"
    end
    redirect_to event_path(@event), notice: 'Box Office sales imported'
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_ticket_sale
    @ticket_sale = TicketSale.find_by(event_id: params[:event_id], id: params[:id])
  end

  def ticket_sales_params
    params.require(:ticket_sale).permit(
      :first_name, :last_name, :email, :affiliation,
      :category, :section, :tickets, :amount
    )
  end
end
