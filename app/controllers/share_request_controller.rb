class ShareRequestController < ApplicationController
  def create
    request = ShareRequest.new(params.merge({:user_id => current_user.id}))
    if request.save
      
    else
      
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
    # to have them log in that desired service.  
    
    auth = current_user.authorizations.where(:provider => provider_name)
    # auth = Authorization.where(:user_id => current_user.id, :provider => provider_name)
    if auth.nil?
      redirect_to "/auth/#{provider_name}"
    end
    
    case provider_name
    when 'facebook'
      # how to get the facebook access_token??
      user = Koala::Facebook::API.new(auth.token)
      if user.nil?
        # TODO: how do we get back here then?? we will have to save off the squeak ID and provider name, etc!!
        redirect_to "/auth/#{provider_name}"
      end
      picture_url = "http://maps.googleapis.com/maps/api/staticmap?center=#{update[:latitude]},#{update[:longitude]}&zoom=13&size=200x200&maptype=roadmap&markers=color:blue%7Clabel:M%7C#{update[:latitude]},#{update[:longitude]}&sensor=true"
      
      puts "Google image url: #{picture_url}"
      
      # Use google's static map api to get an image for the squeak
      id = user.put_wall_post("MapSqueak update at #{Time.now.strftime('')}",{:name => 'squeak name', 
        :link => "#{opts.host}/squeaks/#{confirmation_return_hash['squeak']['id']}",
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
