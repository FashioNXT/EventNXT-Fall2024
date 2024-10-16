# frozen_string_literal: true

json.extract! seat, :id, :category, :total_count, :event_id, :created_at, :updated_at
json.url seat_url(seat, format: :json)
