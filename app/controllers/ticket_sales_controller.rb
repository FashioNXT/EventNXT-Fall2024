# Controller for ticket sales
class TicketSalesController < ApplicationController
  include TicketSalesHelper

  before_action :authenticate_user!
  before_action :set_event
  before_action :set_ticket_sale, only: %i[edit update destroy]
  respond_to :html, :json, :turbo_stream

  def index
    # Allow sorting by a column, defaulting to 'created_at'
    @ticket_sales = @event.ticket_sales.order("#{sort_field_param} #{sort_order_param}")
    respond_with @ticket_sales
  end

  def edit
    respond_with @ticket_sale
  end

  def update
    if @ticket_sale.update(ticket_sales_params)
      flash[:notice] = 'Ticket sale updated'
      respond_with @ticket_sale do |format|
        # Turbo Stream logic is moved to update.turbo_stream.erb
        format.turbo_stream
        # (Fallback) Go back to event dashboard for HTML requests
        format.html { redirect_to event_path(@event) }
      end
    else
      respond_with @ticket_sale do |format|
        # Turbo Stream logic is moved to update.turbo_stream_failure.erb
        format.turbo_stream { render :update_failure }
        # (Fallback) Re-render the edit form for HTML requests
        format.html { render :edit }
      end
    end
  end

  def destroy
    @ticket_sale.destroy
    respond_with @ticket_sale do |format|
      # Turbo Stream logic is moved to destroy.turbo_stream.erb
      format.turbo_stream
      # (Fallback) Go back to event dashboard for HTML requests
      format.html { redirect_to event_path(@event) }
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
    params.require(:ticket_sale).permit(TicketSale.field_names)
  end

  def sort_field_param
    TicketSale.field_names.include?(params[:sort_field].to_sym) ? params[:sort_field] : 'created_at'
  end

  def sort_order_param
    %w[asc desc].include?(params[:sort_order]) ? params[:sort_order] : 'asc'
  end
end
