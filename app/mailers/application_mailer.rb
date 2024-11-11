# frozen_string_literal: true

# class method for application mailer
class ApplicationMailer < ActionMailer::Base
  # <!--===================-->
  # <!--to set the default mailer address-->
  default from: 'suryacherukuri999@gmail.com' # same email can be found at "/config/environments/development.rb"
  # <!--===================-->

  layout 'mailer'

  # <!--===================-->
  # <!--to set the default mailer address-->
  def send_email(to, subject, body, event, guest, rsvp_url, referral_url = nil)
    @event = event
    @guest = guest
    @rsvp_url = rsvp_url
    @referral_url = referral_url # 新添加的行
    mail(to:, subject:) do |format|
      format.html { render inline: ERB.new(body).result(binding).html_safe }
    end
  end

  # <!--===================-->
end
