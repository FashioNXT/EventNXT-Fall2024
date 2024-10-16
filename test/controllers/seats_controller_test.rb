# frozen_string_literal: true

require 'test_helper'

class SeatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @seat = seats(:one)
  end

  test 'should get index' do
    # get seats_url
    get event_seats_path
    assert_response :success
  end

  test 'should get new' do
    # get new_seat_url
    get new_event_seat_path
    assert_response :success
  end

  test 'should create seat' do
    assert_difference('Seat.count') do
      # post seats_url, params: { seat: { category: @seat.category, event_id: @seat.event_id, total_count: @seat.total_count } }
      post event_seats_path,
        params: { seat: { category: @seat.category,
                          event_id: @seat.event_id, total_count: @seat.total_count } }
    end

    # assert_redirected_to seat_url(Seat.last)
    assert_redirected_to event_seat_path(Seat.last)
  end

  test 'should show seat' do
    # get seat_url(@seat)
    get event_seat_path(@seat)
    assert_response :success
  end

  test 'should get edit' do
    # get edit_seat_url(@seat)
    get edit_event_seat_path(@seat)
    assert_response :success
  end

  test 'should update seat' do
    # patch seat_url(@seat), params: { seat: { category: @seat.category, event_id: @seat.event_id, total_count: @seat.total_count } }
    patch event_seat_path(@seat),
      params: { seat: { category: @seat.category, event_id: @seat.event_id,
                        total_count: @seat.total_count } }
    # assert_redirected_to seat_url(@seat)
    assert_redirected_to event_seat_path(@seat)
  end

  test 'should destroy seat' do
    assert_difference('Seat.count', -1) do
      # delete seat_url(@seat)
      delete event_seat_path(@seat)
    end

    # assert_redirected_to seats_url
    assert_redirected_to event_seats_path
  end
end
