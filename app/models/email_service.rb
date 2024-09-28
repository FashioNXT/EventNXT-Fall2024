class EmailService < ApplicationRecord
   
    #attr_accessible :email_template_id, :to, :subject, :body, :event_id, :guest_id
    belongs_to :event, optional: true
    belongs_to :guest, optional: true
end
