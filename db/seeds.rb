# frozen_string_literal: true

# Seed file for creating default data
# Load the data with bin/rails db:seed or create alongside db with db:setup

# Create sample events and store them in variables for reference
event1 = Event.create(name: "Tech Conference 2024", date: "2024-03-10", location: "Austin Convention Center")
event2 = Event.create(name: "Music Festival 2024", date: "2024-04-20", location: "Central Park")

# Create sample guests and store them in variables for reference
guest1 = Guest.create(name: "John Doe", email: "johndoe@example.com", rsvp_link: SecureRandom.hex(10))
guest2 = Guest.create(name: "Jane Smith", email: "janesmith@example.com", rsvp_link: SecureRandom.hex(10))

# Create an example email service record, ensuring both event_id and guest_id are set
EmailService.create(
  event: event1,
  guest: guest1,
  to: guest1.email,
  subject: 'Test Email',
  body: 'This is a test email for the Tech Conference 2024.'
)

# Create email templates with placeholders for dynamic content
rsvp_template = EmailTemplate.find_or_initialize_by(name: 'RSVP Invitation')
rsvp_template.update(
  subject: 'Your Invitation',
  body: 'Hi <%= guest_name %>,<br>You are invited to <%= event_name %> on <%= event_date %> at <%= event_location %>.<br>Please click the link below to RSVP:<br><a href="<%= rsvp_url %>">RSVP Now</a>'
)

referral_template = EmailTemplate.find_or_initialize_by(name: 'Referral Invitation')
referral_template.update(
  subject: 'Invite Your Friends!',
  body: 'Hi there, <br>Invite your friends using this link: <a href="http://localhost:3000/refer_a_friend/<%= random_code %>">Click here</a>.'
)

puts 'Email templates and sample data seeded.'
