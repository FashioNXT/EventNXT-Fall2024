class ApplicationMailer < ActionMailer::Base
  # <!--===================-->
  # <!--to set the default mailer address-->
  default from: "eventnxtapp@gmail.com"   # same email can be found at "/config/environments/development.rb"
  # <!--===================-->
  
  
  layout "mailer"
  
  
  # <!--===================-->
  # <!--to set the default mailer address-->
  def send_email(to, subject, body,event, guest, rsvp_url)

    @event = event
    @guest = guest
    @rsvp_url = rsvp_url
    @refer_url = refer_url


    mail(to: to, subject: subject) do |format|
        format.html { render inline:  ERB.new(body).result(binding).html_safe  }
    end
  end

 
  # <!--===================-->
end
