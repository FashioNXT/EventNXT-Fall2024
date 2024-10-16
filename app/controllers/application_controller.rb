# frozen_string_literal: true

# class ApplicationController < ActionController::Base
#     # <!--===================-->
#     # <!--Devise helper to avoid unauthorized access-->
#   #before_action :sign_out_all_users, only: [:force_sign_out]
#   #before_action :authenticate_user!
#   #skip_before_action :authenticate_user!, only: [:home]

#   protected

#   def after_sign_in_path_for(resource)
#     if resource.nil?
#       # Handle the case when the resource is nil (e.g., not a user)
#       # You can provide a default path or do something else
#       super
#     #Redirect to the specific route after sign-in
#     elsif resource.is_a?(User) # Customize based on your Devise model name
#       #For example, redirect to the dashboard_path after user signs in
#       events_path
#     else
#       super
#     end
#     rescue RuntimeError => e
#       Rails.logger.error("Error in after_sign_in_path_for: #{e.message}")
#       super
#     end
#   end

#   #def forced_sign_out
#     #if current_user.present?
#       #sign_out(current_user)
#       #redirect_to , notice: "All users have been signed out."
#     #end
#   #end
# end

# spec/controllers/application_controller_spec.rb
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protected

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
