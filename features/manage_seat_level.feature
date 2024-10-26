Feature: Checking Seats Functionality

@pre_authenticated
Scenario: Add a guest to an event
  Given I am on the event page "Fake Event"
  When I click on "Add New Seat"
  And I fill in "Category" with "R1"
  And I fill in "Section" with "VIP"
  And I fill in "Total count" with "10"
  And I click on "Create Seat" 
  Then I should see "10" in the seat list

@pre_authenticated
Scenario: Checking the duplicate seats
  Given I am on the event page "Fake Event"
  When I click on "Add New Seat"
  And I fill in "Category" with "R1"
  And I fill in "Section" with "VIP"
  And I fill in "Total count" with "10"
  And I click on "Create Seat" 
  Then I should see "10" in the seat list
  When I click on "Add New Seat"
  And I fill in "Category" with "R1"
  And I fill in "Section" with "VIP"
  And I fill in "Total count" with "10"
  And I click on "Create Seat" 
  And I should see "These seats already exist for this event"
