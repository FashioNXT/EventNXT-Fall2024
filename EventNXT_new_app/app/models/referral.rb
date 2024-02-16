class Referral < ApplicationRecord
  belongs_to :referrer, class_name: 'User'
  belongs_to :event

end
