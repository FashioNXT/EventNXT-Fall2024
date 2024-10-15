json.extract! guest, :id, :first_name, :last_name, :affiliation, :category,
  :alloted_seats, :commited_seats, :guest_commited, :status, :event_id, :created_at, :updated_at
json.url guest_url(guest, format: :json)
