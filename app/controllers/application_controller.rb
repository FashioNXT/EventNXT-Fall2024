# frozen_string_literal: true

#  A base controller for the application,
#  providing a common set of methods and behavior for other controllers to inherit from.
class ApplicationController < ActionController::Base
  protected

  # Redirect to the specific route after sign-in
  def after_sign_in_path_for(resource)
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
