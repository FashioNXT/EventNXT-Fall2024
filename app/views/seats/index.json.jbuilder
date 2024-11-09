# frozen_string_literal: true

json.array! @seats, partial: 'seats/seat', as: :seat
