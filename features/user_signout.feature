Feature: User Sign Out

    Scenario: User successfully signs out and is redirected to the login page
    Given the user is on the current page
    When the user clicks on the "Sign Out" button
    Then the user should see "Signed out successfully"
    And the user should be redirected to the login page


   # Scenario: User successfully signs out and is redirected to the logout page
      #  Given the user is logged in
       # When the user clicks on the Logout button
       # Then the user should be redirected to the logout page at "https://events360.herokuapp.com/logout"