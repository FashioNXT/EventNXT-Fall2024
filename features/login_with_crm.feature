Feature: User can log in with Events360

@omniauth_test
Scenario: Sign in with Events360
  Given I am on the login page
  When I click on "Sign in with Events360"
  Then I should be logged in as "John Doe"
  And I should see "Welcome, John Doe"

@omniauth_test
Scenario: Access feature without sign-in
  Given I am on the index page
  When I click on "Email Service"
  Then I should see "You need to sign in or sign up before continuing."
  And I should be on the index page
  And I should not see "Welcome"

@omniauth_test_failure
Scenario: Failed to Sign in with Events360
Given I am on the login page
When I click on "Sign in with Events360"
Then I should see "Authentication failed. Please try again."
And I should be on the index page
And I should not see "Welcome"

@pre_authenticated
Scenario: Sign out
  Given I am on the events dashboard
  And I should see "Welcome"
  When I click on "Sign Out"
  Then I should be on the index page
  And I should not see "Welcome"