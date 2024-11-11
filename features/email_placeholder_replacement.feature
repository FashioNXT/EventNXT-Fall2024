Feature: Email template placeholder replacement
  As a user
  I want placeholders in RSVP and Referral email templates to be replaced with generic terms
  So that sensitive information is not displayed in the templates

  Scenario: Render RSVP email template with generic placeholders
    Given I have an email with subject "RSVP Invitation"
    When I render the email template
    Then the output should contain "EVENT"
    And the output should contain "FIRST_NAME"
    And the output should contain "LAST_NAME"

  Scenario: Render general email without placeholder replacement
    Given I have an email with subject "General Email"
    When I render the email template
    Then the output should contain "Original Body"
