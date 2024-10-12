class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:events360]
         
         
         # <!--===================-->
         # <!--to add google authentication-->
         #:omniauthable, omniauth_providers: [:google_oauth2]
         # <!--===================-->
  has_many :events
         
  
  
  # <!--===================-->
  # <!--to use google user info to create an account-->
  def self.from_google(info)
    create_with(uid: info[:uid], provider: 'google',
                password: Devise.friendly_token[0, 20]).find_or_create_by!(email: info[:email])
  end
  # <!--===================-->
  def self.from_omniauth(access_token)
    #puts access_token.inspect
    data = access_token.get('/api/user').parsed
    #puts data
    email = data['email']
    name = data['name']
    password = SecureRandom.urlsafe_base64(20).tr('lIO0', 'sxyz')
    # User.find_or_create_by(email:)
    puts "Outer name: #{name}"
    user = User.find_by(email: email)
    puts "user: #{user}"
    user = User.find_or_create_by(email: email)
    user.update(name: name, password: password, password_confirmation: password)
  end
end
