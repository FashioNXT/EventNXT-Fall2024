# frozen_string_literal: true

json.array! @email_services, partial: 'email_services/email_service',
  as: :email_service
