class UsersController < ApplicationController
  def new
    @title = "Sign up"
    @user = User.new
  end
 def show
    @user = User.find(params[:id])
    @title = @user.name
    # without associations: @squeeks = Squeek.find_all_by_user_email(@user.email) 
    #@num_squeeks = @user.squeeks.length # can I do a select count query type thing to make this more efficient??
    @num_squeeks = Squeek.where(:user_email => @user.email).count
    
    # TODO: try to get @user.squeeks.paginate to work ...
    @squeeks = Squeek.where(:user_email => @user.email).paginate(:page => params[:page])
    
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
