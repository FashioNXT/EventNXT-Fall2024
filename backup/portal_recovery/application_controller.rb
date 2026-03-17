class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true
  skip_before_action :verify_authenticity_token, if: -> { controller_name == 'sessions' }

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end
end
