module Constants
  APP_URL = ENV['APP_URL'] || 'http://localhost'
  module Events360
    SYM = :events360
    NAME = 'events360'.freeze
    URL = ENV['EVENT360_URL']
    CLIENT_ID = ENV['EVENT360_CLIENT_ID']
    CLIENT_SECRET = ENV['EVENT360_CLIENT_SECRET']
    module Mock
      USER1 = :events360_user1
      USER2 = :events360_user2
      USER3 = :events360_user3
    end
  end

  module Eventbrite
    SYM = :eventbrite
    NAME = 'eventbrite'.freeze
    URL = ENV['EVENTBRITE_URL'] || 'https://www.eventbrite.com'
    API_URL = ENV['EVENTBRITE_API_URL'] || 'https://www.eventbriteapi.com/v3'
    CLIENT_ID = ENV['EVENTBRITE_CLIENT_ID']
    CLIENT_SECRET = ENV['EVENTBRITE_CLIENT_SECRET']
  end

  module TicketSales
    module Source
      SPREADSHEET = :spreadsheet
      EVENTBRITE = :eventbrite
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
