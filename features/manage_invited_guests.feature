Feature: Adding and managing invited guests

Scenario: Add a guest to an event
  Given I am on the events page
  When I click on the Event
  And I click on the "Add Guest" button
  And I fill in "First Name" with "John"
  And I fill in "Last Name" with "Doe"
  And I fill in "Email" with "john.doe@example.com"
  And I fill in "Affiliation" with  "Example University"
  And I select "Guest List" from the dropdown "Category"
  And I select "VIP" from the dropdown "Selection"
  And I fill in "Alloted Seats" with  "40"
  And I fill in "Commited seats" with  "0"
  And I check the box "Status"
  And I click on the "Create Guest" button
  Then I should see "John Doe" in the guest list

Scenario: Upload guest list 
 Given I am on the events page
 When I click on the Event
 And I click on the "Choose File" button
 And I select file "Guests-full.xlsx"
 And I click on the "Upload" button
 Then I should see the guest list