class SessionsController < ApplicationController
  # so the mobile app can create a session
  protect_from_forgery :except => [:create,:destroy]
  def new
    @title = "Sign in"
  end

  def create
    auth_hash = request.env['omniauth.auth']
    # render :text => auth_hash.inspect
    # return
    if auth_hash.nil?
      e = Message.new("Not successful with omniauth authentication",1)
      
      if request.env["HTTP_USER_AGENT"].include? 'iPhone'
        render :xml => e
      else
        render :text => "Not authenticated"
      end
    else
      provider = auth_hash["provider"]
      success = Message.new("Signed in to #{provider}",0)
      if signed_in? # session[:user_id]
        # Means our user is signed in. Add the authorization to the user
        #User.find(session[:user_id]).add_provider(auth_hash)
        current_user.add_provider(auth_hash)

        #render :text => "You can now login using #{auth_hash["provider"].capitalize} too!"
        # redirect_to current_user
        if request.env["HTTP_USER_AGENT"].include? 'iPhone'
          render :xml => success
        else
          respond_to do | format |
            format.html do
              flash[:success] = success.text
              redirect_to index_path
            end
          end
        end

      else
        # Log him in or sign him up

        #render :text => auth_hash.inspect
        
        # Note that this find/creates an authorization AND also update the credentials
        # AND this will create a user that this authorization belongs to if an authorization
        # is created.
        # TODO: consider creating a User as a separate step
        auth = Authorization.find_or_create(auth_hash)
        
        # Create the session
        # session[:user_id] = auth.user.id
        
        if auth.user
          # authorizations belong to users, so ActiveRecord must do this lookup for us.
          sign_in auth.user
          
          if request.env["HTTP_USER_AGENT"].include? 'iPhone'
            render :xml => success
          else
            respond_to do | format |
              format.html do
                flash[:success] = success.text
                redirect_back_or index_path
              end
            end
          end
        else
          # This is an internal error that shouldn't happen. i.e. we'd have to debug, as opposed to asking the user to do something else
          e = Message.new("Couldn't authorize.",1)
          if request.env["HTTP_USER_AGENT"].include? 'iPhone'
            render :xml => e
          else
            respond_to do | format |
              format.html do
                flash[:error] = e.text
                redirect_to signin_path
              end
            end
          end
        end
        
        # render :text => "Welcome #{auth.inspect}\n\n from #{auth_hash.to_yaml}"
        
        # first check to see if the user was redirected from a URL that requires being logged in
        # e.g. trying to share to facebook. If not, simply redirect to the home URL
        # Note this requires the 'store_location' method to be called earlier if you want
        # to remember what path to go to
        
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

  def failure
    render :xml => Message.new("Auth failure",1)
  end

  def destroy
    services = ""
    if params.include?(:provider)
      sign_out_of(params[:provider])
      services = params[:provider]
    else
      sign_out
      services = "all"
    end

    m = Message.new("Signed out of #{services}",0)
    if request.env["HTTP_USER_AGENT"].include? 'iPhone'
      render :xml => m
    else
      respond_to do | format |
        format.html do
          flash[:success] = m.text
          redirect_to index_path
        end
      end
    end
  end
end
