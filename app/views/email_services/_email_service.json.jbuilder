json.extract! email_service, :id, :to, :subject, :body, :created_at, :updated_at
json.url email_service_url(email_service, format: :json)
