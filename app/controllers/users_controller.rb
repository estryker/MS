class UsersController < ApplicationController
  before_filter :authenticate, :only => [:edit, :update]
  before_filter :correct_user, :only => [:edit, :update]
  
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
  def edit
    @user = User.find(params[:id])
    # we know that @user is the current_user b/c of the before_filter
    @title = "Edit user"
  end
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end
  
  private 
    def authenticate
      deny_access unless signed_in?
    end
    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
end
