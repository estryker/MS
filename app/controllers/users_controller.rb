class UsersController < ApplicationController
  before_filter :authenticate, :only => [:edit, :update, :show]
  before_filter :correct_user, :only => [:edit, :update, :show]
  
  def new
    @title = "Sign up"
    @user = User.new
  end
 def show
    @user = User.find(params[:id])
    @title = @user.name
    
    # without associations: @squeaks = Squeak.find_all_by_user_email(@user.email) 
    @num_squeaks = @user.squeaks.length # can I do a select count query type thing to make this more efficient??
    # @num_squeaks = Squeak.where(:user_email => @user.email).count
    # doesn't work: 
    # @num_squeaks = Squeak.where(:user_id => @user.id).count
    
    # TODO: try to get @user.squeaks.paginate to work ...
    # @squeaks = Squeak.where(:user_email => @user.email).paginate(:page => params[:page])
    # doesn't work:
    @squeaks = Squeak.where(:user_id => @user.id).paginate(:page => params[:page])
    respond_to do | format |
      format.json {render :json=> @squeaks}
      format.xml {render :xml=> @squeaks}
      format.html {render 'show'}
    end
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to MapSqueak!"
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
