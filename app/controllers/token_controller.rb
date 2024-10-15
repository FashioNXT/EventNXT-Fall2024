class TokenController < ApplicationController
  skip_before_action :verify_authenticity_token
  def exchange
    access_token = params[:access_token]
    puts access_token
    # response = access_token.get('/api/users').parsed
    # puts response
    # client =  OAuth2::Client.new(ENV['EVENTNXT_APP_ID'], ENV['EVENTNXT_APP_SECRET'], site: 'http://localhost:3000/')
    # token_params = {
    # code: access_token,
    # redirect_uri: 'http://localhost:3000/auth/events360/callback', # Must match the callback URL configured with the provider
    # grant_type: 'authorization_code'
    # }
    # access = client.auth_code.get_token(access_token, token_params)
    # @user = User.from_omniauth(access)
    info = access_token.get('/api/user').parsed
    info.name
    info.email
    render json: { access_token: }
  end
end
