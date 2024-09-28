# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
    default from: 'notifications@example.com'
  
    def referral_confirmation(friend_email)
      @friend_email = friend_email
     # local example
      @url = 'http://localhost:3000/tickets/new'
      # Heroku example
      # @url = 'http://yourapp.herokuapp.com/tickets/new'
      
      mail(to: @friend_email, subject: 'Confirm Your Ticket Purchase')
    end
    

      
  end
  