Feature: User Login

  As a User
  So that I want to use the App
  I want to login myself to the App.

Background: registered users

  Given the following users exist:
  | email        		| password  |
  | apavankaushik@gmail.com    	| Lion@12   |
  | apavankaushik12@gmail.com	| Pavan@1234|
  | rakeshpothineni@tamu.edu    | Rakesh@123|

  Scenario: register a valid User
  Given I am on the index page
  When  I follow "Log In"
  Then  I should be on the Sign in page
  When  I fill the "Email" as "rakeshpothineni@tamu.edu"
  And   I fill the "Password" as "Rakesh@123"
  And   I press "Log in"
  Then  I should be on the index page

  Scenario: register a invalid User
  Given I am on the index page
  When  I follow "Log In"
  Then  I should be on the Sign in page
  When  I fill the "Email" as "rakeshpothineni@tamu.edu"
  And   I fill the "Password" as "Rakesh@12"
  And   I press "Log in"
  Then  I should be on the Sign in page