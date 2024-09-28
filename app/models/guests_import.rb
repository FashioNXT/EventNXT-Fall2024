class GuestsImport
    include ActiveModel::Model
  
    attr_accessor :event_id, :api_key, :ticketing_website
  
    validates :event_id, presence: true
    validates :api_key, presence: true
    
  
  
  
    def valid
      return false unless valid?
    
    
    
      true
    end
    
  def add_guests(guest_list)
    return if guest_list.nil? || guest_list.empty?

    guest_list.each do |guest_data|
      guest = Guest.new_guest( first_name: guest_data['first_name'], last_name: guest_data['last_name'], email: guest_data['email'], event_id: event_id)
      guest.save
    
    end
    
  end
end