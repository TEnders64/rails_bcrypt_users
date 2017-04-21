class UsersController < ApplicationController
  layout "users"
  def index
    @users = User.all
  end

  def create
    user = User.new( user_params )
    if user.save
      session[:user_id] = user.id 
      redirect_to users_path
    else
      flash[:errors] = user.errors.full_messages
      redirect_to root_path
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end

  def update
    user = User.find(params[:id])
    if !params[:user][:password].blank?
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

  def show
    @user = User.find(params[:id])
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
