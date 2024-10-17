# frozen_string_literal: true

json.array! @guests, partial: 'guests/guest', as: :guest
