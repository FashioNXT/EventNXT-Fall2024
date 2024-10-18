Feature: Adding and managing Seating level for the event

Scenario: Add a seating level for the event
  Given I am on the events page
  When I click on the Event
  And I click on the "Add New Seat" button
  And I fill in "Category" with "Guest List"
  And I fill in "Section" with "VIP"
  And I fill in "Total Count" with "40"
  And I click on the "Create Seat" button
  Then I should see "Guest List" in the Manage Seating Levels list

Scenario: Edit event details
  Given I am on the events page
  When I click on the Event
  And I click on the Edit button in the event details section
  Then I should see the event edit form