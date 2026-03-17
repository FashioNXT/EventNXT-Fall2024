Doorkeeper.configure do
  orm :active_record
  resource_owner_authenticator do
    current_user || redirect_to(new_user_session_url)
  end

  grant_flows %w[authorization_code]
  default_scopes  :public
  optional_scopes :public

  # CRITICAL: Allow HTTP redirects for localhost development
  force_ssl_in_redirect_uri false
  
  skip_client_authentication_for_password_grant true
  use_refresh_token
end
