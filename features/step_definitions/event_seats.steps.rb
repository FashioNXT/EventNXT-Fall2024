Given('I have the following seats') do |table|
  table.hashes.each do |seat|
    @event.seats.create(seat)
  end
end
