class ApplicationMailer < ActionMailer::Base
  # Set default sender email
  default from: 'eventnxtapp@gmail.com'
  layout 'mailer'

  # Sends an email with dynamic event and guest information, and optionally includes RSVP and referral URLs
  def send_email(to, subject, body, event, guest, rsvp_url, referral_url = nil)
    @event = event
    @guest = guest
    @rsvp_url = rsvp_url
    @referral_url = referral_url || new_referral_url(random_code: guest.rsvp_link)
  
    # Render body with dynamic content
    mail(to: to, subject: subject) do |format|
      format.html { render inline: ERB.new(body).result(binding).html_safe }
    end
  end
end
