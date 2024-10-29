# frozen_string_literal: true

class EmailService < ApplicationRecord
  belongs_to :event
  belongs_to :guest
  belongs_to :email_template, optional: true

  validates :to, :subject, :body, presence: true
  # Keeps track of the email sent status with `sent_at` timestamp.
end

