class ShareRequestController < ApplicationController
  def create
    # we expect params to have :squeak_id and :provider. We will determine the :user_id of the requester
    
    squeak = Squeak.find(params[:squeak_id])
    if squeak.nil?
      # throw an appropriate error and redirect to the root_path
      format.html do 
        flash[:error] = "Can't find squeak with id of #{params[:squeak_id]}"
        redirect_to root_path
      end
      format.xml do 
        # do I want a redirect with XML??
      end
    end
    request = ShareRequest.new(params.merge({:user_id => current_user.id}))
    
    # first save to the database, then actually do the share
    # TODO: update a 'confirmed_update' parameter in the share request
    if request.save
      share(squeak,params[:provider])
    else
      err = "Couldn't complete share request"
      
      # redirect to the squeak
      format.html do 
        flash[:error] = err
        redirect_to squeak
      end
      format.xml do 
        render :xml => err
      end
    end
  end

  def show
  end

  # TODO: can I delete this?
  def new
  end

  def index
  end

  :private 
  
  # TODO: I may want to do this by squeak id, not the squeak itself for 
  # ease during redirection
  def share(squeak,provider_name)
    # go through the user's authorizations, get the token and / or the secret. 
    # if nil, or we can't update the service, then we need to reset that authorization, 
    # and redirect them  to the authorization piece (/auth/:provider) 
    # to have them log in that desired service. We store off the current location so that
    # they will be redirected here after authorization. 
    # then, after the update, we can store the share request. 
    # TODO: is there value in keeping track of share requests that fail? 
    
    auth = current_user.authorizations.where(:provider => provider_name)
    # auth = Authorization.where(:user_id => current_user.id, :provider => provider_name)
    if auth.nil?
      store_location
      redirect_to "/auth/#{provider_name}"
    end
    
    case provider_name
    when 'facebook'
      # how to get the facebook access_token??
      user = Koala::Facebook::API.new(auth.token)
      if user.nil?
        store_location
        # note that the callback URL goes to the create method in the session controller
        # which should point us back here when we are done
        redirect_to "/auth/#{provider_name}"
      end
      picture_url = "http://maps.googleapis.com/maps/api/staticmap?center=#{squeak.latitude},#{squeak.longitude}&zoom=13&size=200x200&maptype=roadmap&markers=color:blue%7Clabel:M%7C#{squeak.latitude},#{squeak.longitude}&sensor=true"
      
      puts "Google image url: #{picture_url}"
      
      # Use google's static map api to get an image for the squeak
      id = user.put_wall_post("MapSqueak update at #{Time.now.strftime('')}",{:name => 'squeak name', 
        :link => "#{opts.host}/squeaks/#{squeak.id}",
        :caption => opts.text,
        :description => "the description of the squeak, TBD",
        :picture => picture_url})
    when 'twitter'
      Twitter.configure do |config|
        config.consumer_key = YOUR_CONSUMER_KEY
        config.consumer_secret = YOUR_CONSUMER_SECRET
        config.oauth_token = YOUR_OAUTH_TOKEN
        config.oauth_token_secret = YOUR_OAUTH_TOKEN_SECRET
      end
      Twitter.update("Check this out on MapSqueak: #{}")
    end
  end

end
