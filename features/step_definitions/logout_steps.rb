# features/step_definitions/logout_05oct_steps.rb

Given('the user is on the current page') do
    @user = User.create!(email: 'test@example.com', password: 'password')  # Create a test user
    login_as(@user, scope: :user)  # Log the user in using Devise's login_as helper
    visit root_path  # Navigate to the homepage or dashboard
    expect(page).to have_current_path(root_path)  # Verify the user is on the expected page
  end
  
  When('the user clicks on the "Sign Out" button') do
    click_link 'Sign Out'  # Click the 'Sign Out' link
  end
  
  Then('the user should see "Signed out successfully"') do
    expect(page).to have_content('Signed out successfully')  # Check for the flash message
  end
  
  Then('the user should be redirected to the login page') do
    expect(page).to have_current_path(new_user_session_path)  # Check if redirected to login page
  end
  