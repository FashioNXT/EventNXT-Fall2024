Feature: Sending emails and managing email templates

Scenario: Creating an email service as a logged-in user
    Given I am logged in as "user@example.com"
    And I am on the Email services page
    When I click on "Add New Email" button
    And I click on "Create Email service" button

