Feature: Sending emails and managing email templates

Scenario: Creating an email service
    Given I am on the Email service page
    And I click on "Add New Email" button
    And I click on "Create Email service" button

Scenario: Referring a friend
    Given I am on the confirmation page of a created email service
    And I fill in "Friend's Email Address" with "friend@example.com"
    And I click on "Submit" button

Scenario: Friend is purchasing tickets
    Given I am on the purchase tickets page of a created email service
    And I fill in "Number of Tickets:" with "5"