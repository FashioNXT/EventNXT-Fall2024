Feature: Adding and managing invited guests

@pre_authenticated
Scenario: Add a guest to an event
  Given I am on the event page "Fake Event"
  And I have the following seats
  | category | section | total_count |
  | VIP      | A       | 100          |
  When I click on "Add Guest"
  And I fill in "First Name" with "John"
  And I fill in "Last Name" with "Doe"
  And I fill in "Email" with "john.doe@example.com"
  And I fill in "Affiliation" with "Example University"
  And I select "VIP" from the dropdown "Category"
  And I select "A" from the dropdown "Section"
  And I fill in "Allocated Seats" with "40"
  And I fill in "Commited Seats" with "0"
  And I check the box "Status"
  And I click on "Create Guest" 
  Then I should see "John Doe" in the guest list

@pre_authenticated
Scenario: Upload guest list 
  Given I am on the event page "Fake Event"
  #And I click on "Choose File"
  And I attach the file "guests.xlsx" to the field "guest-list-attach"
  And I click on "Upload Guest"
  Then I should see "Anirith" in the guest list
  Then I should see "Rakesh" in the guest list
  Then I should see "Pavan" in the guest list