# frozen_string_literal: true

module Constants
  APP_URL = ENV['APP_URL'] || 'http://localhost'

  module EventNXT
    SYM = :eventnxt
    NAME = 'eventnxt'
    URL = ENV['EVENTNXT_URL']
    CLIENT_ID = ENV['EVENTNXT_CLIENT_ID']
    CLIENT_SECRET = ENV['EVENTNXT_CLIENT_SECRET']
    module Mock
      USER1 = :eventnxt_user1
      USER2 = :eventnxt_user2
      USER3 = :eventnxt_user3
    end
  end

  module Eventbrite
    SYM = :eventbrite
    NAME = 'eventbrite'
    URL = ENV['EVENTBRITE_URL'] || 'https://www.eventbrite.com'
    API_URL = ENV['EVENTBRITE_API_URL'] || 'https://www.eventbriteapi.com/v3'
    CLIENT_ID = ENV['EVENTBRITE_CLIENT_ID']
    CLIENT_SECRET = ENV['EVENTBRITE_CLIENT_SECRET']
  end

  module CastNXT
    SYM = :castnxt
    NAME = 'castnxt'
    BASE_URL = ENV['CASTNXT_BASE_URL'] || 'https://castnxt.com'
    CLIENT_ID = ENV['CASTNXT_CLIENT_ID']
    CLIENT_SECRET = ENV['CASTNXT_CLIENT_SECRET']
  end

  module PlaNXT
    SYM = :planxt
    NAME = 'planxt'
    BASE_URL = ENV['PLANXT_BASE_URL'] || 'https://planxt.com'
    CLIENT_ID = ENV['PLANXT_CLIENT_ID']
    CLIENT_SECRET = ENV['PLANXT_CLIENT_SECRET']
  end

  module TicketSales
    module Source
      SPREADSHEET = 'spreadsheet'
      EVENTBRITE = 'eventbrite'
    end

    module Field
      EMAIL = :email
      CATEGORY = :category
      SECTION = :section
      TICKETS = :tickets
      COST = :cost
      FLAGS = :flags
    end

    module Flags
      INVALID_CATEGORY_SECTION = :invalid_category_section
    end
  end
end
