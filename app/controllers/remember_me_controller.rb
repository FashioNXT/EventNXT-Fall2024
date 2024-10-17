# frozen_string_literal: true

class RememberMeController < ApplicationController
  def clear_remember_me
    if user_signed_in?
      current_user.forget_me! # Clears the remember-me token
      redirect_to root_path, notice: 'Remember-me token has been cleared.'
    else
      redirect_to root_path,
        alert: 'You need to sign in or sign up before continuing.'
    end
  end
end
