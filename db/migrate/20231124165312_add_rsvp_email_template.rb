class AddRsvpEmailTemplate < ActiveRecord::Migration[7.0]
  def change
    EmailTemplate.create(
      name: 'RSVP_Invitation',
      subject: 'RSVP Invitation',
      body: File.read(Rails.root.join('app', 'views', 'email_services', 'email_templates', 'rsvp_invitation_email.html.erb'))
    )
  end
end

