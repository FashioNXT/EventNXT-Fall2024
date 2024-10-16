# frozen_string_literal: true

require 'test_helper'

class GuestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @guest = guests(:one)
  end

  test 'should get index' do
    # get guests_url
    get event_guests_path
    assert_response :success
  end

  test 'should get new' do
    # get new_guest_url
    get new_event_guest_path
    assert_response :success
  end

  test 'should create guest' do
    assert_difference('Guest.count') do
      # post guests_url, params: { guest: { affiliation: @guest.affiliation, alloted_seats: @guest.alloted_seats, category: @guest.category, commited_seats: @guest.commited_seats, event_id: @guest.event_id, first_name: @guest.first_name, guest_commited: @guest.guest_commited, last_name: @guest.last_name, status: @guest.status } }
      post event_guests_path,
        params: { guest: { affiliation: @guest.affiliation, alloted_seats: @guest.alloted_seats, category: @guest.category,
                           commited_seats: @guest.commited_seats, event_id: @guest.event_id, first_name: @guest.first_name, guest_commited: @guest.guest_commited, last_name: @guest.last_name, status: @guest.status } }
    end

    # assert_redirected_to guest_url(Guest.last)
    assert_redirected_to event_guest_path(Guest.last)
  end

  test 'should show guest' do
    # get guest_url(@guest)
    get event_guest_path(@guest)
    assert_response :success
  end

  test 'should get edit' do
    # get edit_guest_url(@guest)
    get edit_event_guest_path(@guest)
    assert_response :success
  end

  test 'should update guest' do
    # patch guest_url(@guest), params: { guest: { affiliation: @guest.affiliation, alloted_seats: @guest.alloted_seats, category: @guest.category, commited_seats: @guest.commited_seats, event_id: @guest.event_id, first_name: @guest.first_name, guest_commited: @guest.guest_commited, last_name: @guest.last_name, status: @guest.status } }
    patch event_guest_path(@guest),
      params: { guest: { affiliation: @guest.affiliation, alloted_seats: @guest.alloted_seats, category: @guest.category,
                         commited_seats: @guest.commited_seats, event_id: @guest.event_id, first_name: @guest.first_name, guest_commited: @guest.guest_commited, last_name: @guest.last_name, status: @guest.status } }
    # assert_redirected_to guest_url(@guest)
    assert_redirected_to event_guest_path(@guest)
  end

  test 'should destroy guest' do
    assert_difference('Guest.count', -1) do
      # delete guest_url(@guest)
      delete event_guest_path(@guest)
    end

    # assert_redirected_to guests_url
    assert_redirected_to event_guests_path
  end
end
