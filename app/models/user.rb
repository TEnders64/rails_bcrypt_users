class User < ActiveRecord::Base
  has_secure_password
  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]+)\z/i

  validates :name, presence: true, length: {minimum: 2}
  validates :email, presence: true, format: {with: EMAIL_REGEX}, uniqueness: true
  validates :password, presence: true, length: {minimum: 8}, if: "!password.nil?"

  before_save :email_lowercase
  def email_lowercase
    self.email.downcase!
  end
  
end
