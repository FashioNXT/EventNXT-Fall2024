#class TokenController < ApplicationController
 # skip_before_action :verify_authenticity_token
  #def exchange
   #   access_token = params[:access_token]
     # puts access_token
      #response = access_token.get('/api/users').parsed
      #puts response
      #client =  OAuth2::Client.new(ENV['EVENTNXT_APP_ID'], ENV['EVENTNXT_APP_SECRET'], site: 'http://localhost:3000/')
      #token_params = {
        #code: access_token,
        #redirect_uri: 'http://localhost:3000/auth/events360/callback', # Must match the callback URL configured with the provider
        #grant_type: 'authorization_code'
      #}
      #access = client.auth_code.get_token(access_token, token_params)
      #@user = User.from_omniauth(access)
     # info = access_token.get('/api/user').parsed
      #name = info.name
      #email = info.email
      #render json: { access_token: access_token }
 # end
#end


class TokenController < ApplicationController
  skip_before_action :verify_authenticity_token

  def exchange
    # Retrieve the raw access token from params
    raw_token = params[:access_token]

    # Initialize the OAuth2 client with the base URL from ENV
    client = OAuth2::Client.new(
      ENV['EVENTNXT_APP_ID'], 
      ENV['EVENTNXT_APP_SECRET'], 
      site: ENV['NXT_APP_URL']  # Use environment variable for the CRM base URL
    )

    # Create the access token object from the raw token string
    access_token = OAuth2::AccessToken.from_hash(client, { access_token: raw_token })

    # Make a request to get user information
    info = access_token.get('/api/user').parsed

    # Extract the name and email from the response
    name = info['name']
    email = info['email']

    # Return the access token in the response (or other relevant data)
    render json: { access_token: raw_token, name: name, email: email }
  end
end

