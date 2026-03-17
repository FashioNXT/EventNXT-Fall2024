class Api::UsersController < ApplicationController
  before_action :doorkeeper_authorize!
  respond_to :json

  def show
    user = User.find(doorkeeper_token.resource_owner_id)
    render json: {
      id: user.id.to_s,
      email: user.email,
      name: user.name,
      role: (user.respond_to?(:role) ? user.role : "Producer")
    }
  end
end
