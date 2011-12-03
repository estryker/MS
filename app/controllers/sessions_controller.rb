class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end

  def create
    user = User.authenticate(params[:session][:email],
                             params[:session][:password])
    if user.nil?
      respond_to do |format |
        format.html do 
          flash.now[:error] = "Invalid email/password combination."
          @title = "Sign in"
          render 'new'
        end
        format.xml do 
          render :xml => {:error=>'no such user/password'}
        end
      end
    else
      sign_in user
      respond_to do |format|
        format.html do 
          redirect_to user
        end
        format.xml do 
          #TODO: make this more secure by adding HMAC
          render :xml => {:user_id => "#{current_user.id}"}
        end
      end
    end
  end
  def destroy
    sign_out
    redirect_to root_path
  end
end
