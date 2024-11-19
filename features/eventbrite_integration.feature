Feature: Eventbrite integration

@omniauth_except_crm
Scenario: Connect to Eventsbrite account
  Given I have the following Eventbrite Events
  | id | name |
  | 1  | First Event |
  | 2  | Second Event |
  Given I am on the event page "Eventbrite Test Suite" with ticket source from Eventbrite
  When I click on "Connect to Eventbrite"
  And I am on the event page "Eventbrite Test Suite" with ticket source from Eventbrite 
  Then I should see "Connected: Eventbrite"
  And I should not see "No events found."
  And I should see the external events list showing "First Event, Second Event"


@omniauth_except_crm
Scenario: Show Eventbrite Data
  Given I have the following Eventbrite Events
  | id | name |
  | 1  | First Event |
  | 2  | Second Event |
  And I have the following Eventbrite data
  | ticket_class | quantity | cost    |
  | General      | 10       | $20     |
  | VIP          | 5        | $100.50 |
  And I have connected to Eventbrite
  Given I am on the event page "Eventbrite Test Suite" with ticket source from Eventbrite
  When I select "First Event" from the dropdown labeled "Select an external event"
  And I click on "Show Ticket Sales"
  Then I should see "General"
  And I should see "VIP"
  And I should see "100.5"


@omniauth_except_crm
Scenario: Show warnning on categories and sections if not configured
  Given I have the following Eventbrite Events
  | id | name |
  | 1  | First Event |
  And I have the following Eventbrite data
  | ticket_class | quantity | cost    |
  | General      | 10       | $20     |
  | VIP          | 5        | $100.50 |
  And I have connected to Eventbrite
  Given I am on the event page "Eventbrite Test Suite" with ticket source from Eventbrite
  And I have the following seats
  | category | section | total_count |
  | backup   | A       | 50          |  
  When I select "First Event" from the dropdown labeled "Select an external event"
  And I click on "Show Ticket Sales"
  Then I should not see "Connect to Eventbrite"
  Then I should see "General !"
  And I should see "VIP !"


@omniauth_except_crm
Scenario: Show no warnnings when categories and sections have been configured
  Given I have the following Eventbrite Events
  | id | name |
  | 1  | First Event |
  And I have the following Eventbrite data
  | ticket_class | quantity | cost    |
  | General      | 10       | $20     |
  | VIP          | 5        | $100.50 |
  And I have connected to Eventbrite
  Given I am on the event page "Eventbrite Test Suite" with ticket source from Eventbrite
  And I have the following seats
  | category | section | total_count |
  | General  | General | 100         |  
  | backup   | A       | 50          |  
  | VIP      | VIP     | 10          |  
  When I select "First Event" from the dropdown labeled "Select an external event"
  And I click on "Show Ticket Sales"
  Then I should not see "Connect to Eventbrite"
  Then I should not see "General !"
  And I should not see "VIP !"