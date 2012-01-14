class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end

  def create
    #debug = request.env.inspect # request.env.keys.find_all {|k| k =~ /auth/}.join(' ')
    #render :text => debug
    #return
    
    # total hack. TODO: make an istherea.com app and corresponding omniauth strategy
    if request.env.has_key?('omniauth.auth')
      auth = request.env['omniauth.auth']
      unless @auth = Authorization.find_from_hash(auth)
        # Create a new user or add an auth to existing user, depending on
        # whether there is already a user signed in.
        @auth = Authorization.create_from_hash(auth, current_user)
      end
    # Log the authorizing user in.
    self.current_user = @auth.user
    else
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
      end
    end
    respond_to do |format|
      format.html do
        redirect_to current_user
      end
      format.xml do
      #TODO: make this more secure by adding HMAC
        render :xml => {:user_id => "#{current_user.id}"}
      end
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
