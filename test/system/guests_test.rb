require "application_system_test_case"

class GuestsTest < ApplicationSystemTestCase
  setup do
    @guest = guests(:one)
  end

  test "visiting the index" do
    visit guests_url
    assert_selector "h1", text: "Guests"
  end

  test "should create guest" do
    visit guests_url
    click_on "New guest"

    fill_in "Affiliation", with: @guest.affiliation
    fill_in "Alloted seats", with: @guest.alloted_seats
    fill_in "Category", with: @guest.category
    fill_in "Commited seats", with: @guest.commited_seats
    fill_in "Event", with: @guest.event_id
    fill_in "First name", with: @guest.first_name
    fill_in "Guest commited", with: @guest.guest_commited
    fill_in "Last name", with: @guest.last_name
    check "Status" if @guest.status
    click_on "Create Guest"

    assert_text "Guest was successfully created"
    click_on "Back"
  end

  test "should update Guest" do
    visit guest_url(@guest)
    click_on "Edit this guest", match: :first

    fill_in "Affiliation", with: @guest.affiliation
    fill_in "Alloted seats", with: @guest.alloted_seats
    fill_in "Category", with: @guest.category
    fill_in "Commited seats", with: @guest.commited_seats
    fill_in "Event", with: @guest.event_id
    fill_in "First name", with: @guest.first_name
    fill_in "Guest commited", with: @guest.guest_commited
    fill_in "Last name", with: @guest.last_name
    check "Status" if @guest.status
    click_on "Update Guest"

    assert_text "Guest was successfully updated"
    click_on "Back"
  end

  test "should destroy Guest" do
    visit guest_url(@guest)
    click_on "Destroy this guest", match: :first

    assert_text "Guest was successfully destroyed"
  end
end
