# frozen_string_literal: true

# EmailTemplate
class EmailTemplate < ApplicationRecord
  validates :name, presence: true
  validates :body, presence: true
end
