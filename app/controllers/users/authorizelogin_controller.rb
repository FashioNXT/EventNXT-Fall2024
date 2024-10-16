# frozen_string_literal: true

require 'net/http'
module Users
  class AuthorizeloginController < ApplicationController
    def authorize_event360
      # Redirect the user to the Event360 authorization endpoint with necessary parameters
      events_360_app_url = ENV['NXT_APP_URL'].to_s
      events_360_client_id = ENV['NXT_APP_ID'].to_s
      event_nxt_url = ENV['EVENT_NXT_APP_URL'].to_s
      puts '======================================='
      puts events_360_app_url
      puts events_360_client_id
      puts event_nxt_url
      puts '======================================='
      redirection_link = "#{events_360_app_url}/oauth/authorize?client_id=#{events_360_client_id}&redirect_uri=#{event_nxt_url}/auth/events360/callback&response_type=code&scope=public"
      redirect_to redirection_link, allow_other_host: true
      # redirect_to "http://localhost:3002/oauth/authorize?client_id=yG-KwY8Vkonk2_ROwf0CYvnW-WB-KfqUpSKoTFY2lro&redirect_uri=http://localhost:3000/auth/events360/callback&response_type=code&scope=public", allow_other_host: true
    end
  end
end
