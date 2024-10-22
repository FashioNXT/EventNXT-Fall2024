Feature: Adding and managing invited guests

Scenario: Add a guest to an event
  Given I am on the event page "Fake Event"
  Then I add the following seats for the event "Fake Event"
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

Scenario: Upload guest list 
  Given I am on the event page "Fake Event"
  #And I click on "Choose File"
  And I attach the file "guests.xlsx" to the field "guest-list-attach"
  And I click on the "Upload Guest" button
  Then I should see "Anirith" in the guest list
  Then I should see "Rakesh" in the guest list
  Then I should see "Pavan" in the guest list
  
Scenario: Check for duplicate emails when uploading guest list
  Given I am on the event page "Fake Event"
  And I attach the file "guests.xlsx" to the field "guest-list-attach"
  And I click on the "Upload Guest" button
  And I attach the file "new_ticketlist.xlsx" to the field "guest-list-attach"
  And I click on the "Upload Guest" button
  Then I should see "Duplicate emails found" in the error messages

Scenario: Check for empty email found when uploading guest list
  Given I am on the event page "Fake Event"
  And I attach the file "check_email.xlsx" to the field "guest-list-attach"
  And I click on the "Upload Guest" button
  Then I should see "Empty emails found" in the error messages
