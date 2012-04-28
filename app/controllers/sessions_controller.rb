class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end

  def create
    auth_hash = request.env['omniauth.auth']
    # render :text => auth_hash.inspect
    # return
    if auth_hash.nil?
      render :text => "Not authenticated"
    else
      if signed_in? # session[:user_id]
        # Means our user is signed in. Add the authorization to the user
        #User.find(session[:user_id]).add_provider(auth_hash)
        current_user.add_provider(auth_hash)

        #render :text => "You can now login using #{auth_hash["provider"].capitalize} too!"
        # redirect_to current_user
        redirect_to root_path
      else
      # Log him in or sign him up
        #render :text => auth_hash.inspect
        
        # Note that this find/creates an authorization AND also update the credentials
        auth = Authorization.find_or_create(auth_hash)
        
        # Create the session
        # session[:user_id] = auth.user.id

        if auth.user
          # authorizations belong to users, so ActiveRecord must do this lookup for us. 
          sign_in auth.user
        else
          flash[:error] = "Couldn't authorize."
          redirect_to signin_path
        end
        
        # render :text => "Welcome #{auth.inspect}\n\n from #{auth_hash.to_yaml}"
        
        # first check to see if the user was redirected from a URL that requires being logged in
        # e.g. trying to share to facebook. If not, simply redirect to the home URL
        # Note this requires the 'store_location' method to be called earlier if you want
        # to remember what path to go to
        redirect_back_or root_path
      end
    end

  #  user = User.authenticate(params[:session][:email],
   #                          params[:session][:password])
   # if user.nil?
   #   respond_to do |format |
   #     format.html do 
   #       flash.now[:error] = "Invalid email/password combination."
   #       @title = "Sign in"
   #       render 'new'
   #     end
   #     format.xml do 
   #       render :xml => {:error=>'no such user/password'}
   #     end
   #   end
   # else
   #   sign_in user
   #   respond_to do |format|
   #     format.html do 
   #       redirect_to user
   #     end
   #     format.xml do 
   #       #TODO: make this more secure by adding HMAC
   #       render :xml => {:user_id => "#{current_user.id}"}
   #     end
   #   end
   # end
  end
  def destroy
    sign_out
    redirect_to root_path
  end
end
