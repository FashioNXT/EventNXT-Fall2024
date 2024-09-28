Feature: register an User

  As a User
  So that I want to use the App
  I want to register myself to the App.

Background: registered users

  Given the following users exist:
  | email        		| password  |
  | apavankaushik@gmail.com    	| Lion@12   |
  | apavankaushik12@gmail.com	| Pavan@1234|

Scenario: register a valid User
  Given I am on the index page
  When  I follow "Sign up"
  Then  I should be on the Sign up page
  When  I fill the "Email" as "apavankaushik12@gmail.com"
  And   I fill the "Password" as "Pavan@1234"
  And   I fill the "Password confirmation" as "Pavan@1234"
  And   I press "Sign up"
  Then  I should be on the index page

Scenario: Do not register invalid user
  Given I am on the index page
  When  I follow "Sign up"
  Then  I should be on the Sign up page
  When  I fill the "Email" as "apavankaushik12@gmail.com"
  And   I fill the "Password" as "Pavan@1234"
  And   I fill the "Password confirmation" as "Pavan@12345"
  And   I press "Sign up"
  Then  I should be on the sign up page
