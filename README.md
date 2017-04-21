## Rails BCrypt Users

What I wanted to look into was beyond Login and Registration features when using BCrypt.

- What if users want to update their passwords?
- What if users want to update their information without updating their passwords?
- Would we have to worry about BCrypt and our private user_params getting in the way of updates?

Well, BCrypt `has_secure_password` only works on create, so by having a minimum length for password validations on top of `has_secure_password` doing all of its password_confirmation matching and such, we can then turn off and on the ability to validate a user's password when they want to do an update to their password. Otherwise, I can leave the password out of it.

The kicker is in the model file. ```validates :password, presence: true, length: {minimum: 8}, if: "!password.nil?"```

That's the conditional way of checking whether or not to enforce this password validation. Bcrypt's validation does the majority of the work checking for presence and confirmation fields. This way, if someone trying to do a password change after having already registered, will only be under the scrutiny of this validation if they so choose to enter a new password.

#### [views/users/edit.html.erb](https://github.com/TEnders64/rails_bcrypt_users/blob/master/app/views/users/edit.html.erb)
![Edit a User](https://github.com/TEnders64/rails_bcrypt_users/blob/master/BCrypt_Users.png)


#### [users.rb](https://github.com/TEnders64/rails_bcrypt_users/blob/master/app/controllers/users.rb)
```ruby
  def update
    user = User.find(params[:id])
    if !params[:user][:password].blank? # I only do this check to provide a more informative notice on the show page
      puts "NEW PASSWORD"
      if user.update( user_params )
        redirect_to user_path, id: user.id, notice: 'Password and Info Updated!'
      else
        flash[:errors] = user.errors.full_messages
        redirect_to edit_path, id: user.id 
      end
    else 
      puts "NO PASSWORD CHANGE"
      if user.update( user_params )
        redirect_to user_path, id: user.id, notice: 'Name and/or Email Updated!'
      else
        flash[:errors] = user.errors.full_messages        
        redirect_to edit_path, id: user.id 
      end
    end
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
```

#### [user.rb](https://github.com/TEnders64/rails_bcrypt_users/blob/master/app/models/user.rb)
```ruby
class User < ActiveRecord::Base
  has_secure_password
  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]+)\z/i

  validates :name, presence: true, length: {minimum: 2}
  validates :email, presence: true, format: {with: EMAIL_REGEX}, uniqueness: true
  validates :password, presence: true, length: {minimum: 8}, if: "!password.nil?" # <- that's the conditional way of checking whether or not to enforce this password validation. bcrypt's validation up above does the majority of the work

  before_save :email_lowercase
  def email_lowercase
    self.email.downcase!
  end
end