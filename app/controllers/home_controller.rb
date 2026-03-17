class HomeController < ApplicationController
  layout false

  def index
    @authenticated = session[:user_email].present?
  end

  def login
    session[:user_email] = "tito@events360.com"
    redirect_to root_path
  end

  def logout
    reset_session
    redirect_to root_path
  end
end
