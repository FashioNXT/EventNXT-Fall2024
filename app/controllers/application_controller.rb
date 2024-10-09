class ApplicationController < ActionController::Base
  protected

  # Redirect to events_path after sign-in for users
  def after_sign_in_path_for(resource)
    begin
      if resource.is_a?(User)
        events_path
      else
        super
      end
    rescue RuntimeError => e
      Rails.logger.error("Error in after_sign_in_path_for: #{e.message}")
      super
    end
  end

  # Redirect to login page after sign-out
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path  # Redirects to login page after sign-out
  end
end
