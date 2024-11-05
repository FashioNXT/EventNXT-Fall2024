# frozen_string_literal: true

# EmailServicesHelper
module EmailServicesHelper
    def render_template_with_generic_placeholders(email)
      # Determine template name based on subject
      template_name = if email[:subject].match?(/RSVP/i)
                        'rsvp_invitation_email'
                      elsif email[:subject].match?(/Referral/i)
                        'referral_invitation_email'
                      else
                        nil
                      end
  
      # If template is RSVP or Referral, load and replace placeholders with generic terms
      if template_name
        template_path = Rails.root.join('app', 'views', 'email_services', 'email_templates', "#{template_name}.html.erb")
        if File.exist?(template_path)
          template_content = File.read(template_path)
  
          # Replace placeholders with specific generic terms
          template_content.gsub!(/<%= @event.title %>/, 'EVENT')
          template_content.gsub!(/<%= @guest.first_name %>/, 'FIRST_NAME')
          template_content.gsub!(/<%= @guest.last_name %>/, 'LAST_NAME')
          template_content.gsub!(/<%= @event.datetime %>/, 'EVENT_DATE')
          template_content.gsub!(/<%= @event.description %>/, 'EVENT_DESCRIPTION')
          template_content.gsub!(/<%= @event.address %>/, 'EVENT_ADDRESS')
          template_content.gsub!(/<%=.*?%>/, '[placeholder]') # Catch any remaining placeholders generically
  
          return template_content
        else
          return "<p>[File for #{template_name} not found]</p>"
        end
      end
  
      # For other templates, render email body as is
      email[:body]
    end
  end
  