module TicketVendor
  # Parameters for Vendor Service
  class Config
    attr_reader :event_id,
      :category_source_key,
      :section_source_key,
      :tickets_source_key,
      :cost_source_key

    def initialize(
      event_id,
      category_source_key,
      section_source_key,
      tickets_source_key,
      cost_source_key
    )
      @event_id = event_id
      @category_source_key = category_source_key
      @section_source_key = section_source_key
      @tickets_source_key = tickets_source_key
      @cost_source_key = cost_source_key
    end
  end
end
