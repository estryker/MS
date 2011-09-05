class UsersController < ApplicationController
  def new
    @title = "Sign up"
    @user = User.new
  end
 def show
    @user = User.find(params[:id])
    @title = @user.name
    @squeeks = Squeek.find_all_by_user_email(@user.email)
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to MapSqueek!"
      redirect_to @user
    else
      @title = "Sign up"
      render 'new'
    end
  end
  
end
