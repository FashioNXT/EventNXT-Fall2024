Feature: Eventbrite integration

@omniauth_except_crm
Scenario: Connect to Eventsbrite account
  Given I am on the event page "Eventbrite Test Suite"
  And I have the following Eventbrite Events
  | id | name |
  | 1  | First Event |
  | 2  | Second Event |
  When I click on "Connect to Eventbrite"
  And I am on the event page "Eventbrite Test Suite" 
  Then I should see "Connected: Eventbrite"
  And I should not see "No events found."
  And I should see the external events list showing "First Event, Second Event"