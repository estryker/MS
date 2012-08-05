module SessionsHelper
  def anonymous_user
    anonymous_email = 'anonymous@anonymous.com'
    user = User.new(:name => 'Anonymous', :email=>anonymous_email)
  end
  
  def sign_in(user)
    current_user = user
    session[:user_id] = user.id
  end
  
  def signed_in?
    !self.current_user.nil?
  end
  
  def signed_in_to?(service)
    signed_in? and  current_user.authorizations.any? {|a| a.provider.to_s == service.to_s and not a.token.nil? }
  end
  
  # signs people out of all services
  def sign_out
    current_user.authorizations.each do | a |
      a.token = nil
      a.secret = nil
      a.save
    end
    current_user = nil
    session[:user_id] = nil
  end

  def sign_out_of(service)
     # there should only be one. But for now, just set them all to nil
     current_user.authorizations.where(:provider => service).each do | a |
      a.token = nil
      a.secret = nil
      a.save
     end
    
    # only make the current user nil after all services are signed out of
    if current_user.authorizations.all? {|a| a.token.nil? }
      current_user = nil
      session[:user_id] = nil
    end

  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= user_from_id
  end
  
  def current_user?(user)
    user == current_user
  end
  
  def deny_access
    store_location
    redirect_to signin_path, :notice => "Please sign in to access this page."
  end
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end
  
  private

   # def user_from_remember_token
   #   User.authenticate_with_salt(*remember_token)
   # end

    #def remember_token
    #  cookies.signed[:remember_token] || [nil, nil]
    #end
    def user_from_id
      user = nil
      if session.has_key? :user_id
        user = User.find(session[:user_id])
      end
      user
    end
    
    def store_location
      session[:return_to] = request.fullpath
    end

    def clear_return_to
      session[:return_to] = nil
    end
end
