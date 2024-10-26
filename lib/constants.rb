module Constants
  APP_URL = ENV['APP_URL']
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
end
