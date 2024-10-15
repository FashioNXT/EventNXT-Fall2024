# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
EmailService.create(
  to: 'test@example.com',
  subject: 'Test Email',
  body: 'This is a test email'
)

rsvp_template = EmailTemplate.find_or_initialize_by(name: 'RSVP Invitation')
rsvp_template.update(
  subject: 'Your Invitation',
  body: '...'
)

referral_template = EmailTemplate.find_or_initialize_by(name: 'Referral Invitation')
referral_template.update(
  subject: 'Invite Your Friends!',
  body: 'Hi there, <br>Invite your friends using this link: <a href="http://localhost:3000/refer_a_friend">Click here</a>.'
)

puts 'Email templates seeded.'
