# frozen_string_literal: true

# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  default from: 'suryacherukuri999@gmail.com'

  def referral_confirmation(friend_email)
    @friend_email = friend_email
    # local example
    @url = "#{ENV['APP_URL']}/tickets/new"
    # Heroku example
    # @url = 'http://yourapp.herokuapp.com/tickets/new'

    mail(to: @friend_email, subject: 'Confirm Your Ticket Purchase')
  end
end
