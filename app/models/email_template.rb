# frozen_string_literal: true

class EmailTemplate < ApplicationRecord
  has_many :email_services

  validates :name, :subject, :body, presence: true
end
