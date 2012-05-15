class ShareRequestsController < ApplicationController
  
  # so the mobile app can create a session
  protect_from_forgery :except => [:create]
  
  include ActionView::Helpers::DateHelper
  include ApplicationHelper

  def create
    # we expect params to have :squeak_id and :provider. We will determine the :user_id of the requester

    squeak = Squeak.find(params[:squeak_id])

    if squeak.nil?
      # throw an appropriate error and redirect to the root_path
      #format.html do
      e = Message.new("Can't find squeak with id of #{params[:squeak_id]}")
      
      if request.env["HTTP_USER_AGENT"].include? 'iPhone'
        render :xml => e
      else
        respond_to do | format |     
          format.html do 
            flash[:error] = e.text
            redirect_to root_path
          end
        end
      end
      #end
      #format.xml do
      # do I want a redirect with XML??
      #  render :xml => "No squeak with that ID found"
      #end
    else
      if signed_in_to?(params[:provider])
        #request = ShareRequest.new(params.merge({:user_id => current_user.id}))
        share_request = ShareRequest.new({:user_id => current_user.id,:squeak_id => params[:squeak_id],:provider=>params[:provider]})

        # first save to the database, then actually do the share
        # TODO: update a 'confirmed_update' parameter in the share request
        if share_request.save
          
          redirect_path = share(squeak,params[:provider])
          
          success = Message.new("Squeak successfully shared on #{params[:provider]}",0)
          if request.env["HTTP_USER_AGENT"].include? 'iPhone'
            render :xml => success
          else
            respond_to do | format |     
              format.html do 
                flash[:message] = success.text
                redirect_to root_path
              end
            end
          end
        else
          e = Message.new("Couldn't complete share request",1)
          if request.env["HTTP_USER_AGENT"].include? 'iPhone'
            render :xml => e
          else
            respond_to do | format |     
              format.html do 
                flash[:error] = e.text
                redirect_to squeak
              end
            end
          end
        end
      else
        #format.html do 
        e = Message.new("User must signin to #{params[:provider]} to share on #{params[:provider]}",1)
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
    # if nil, or we can't update the provider, then we need to reset that authorization,
    # and redirect them  to the authorization piece (/auth/:provider)
    # to have them log in that desired provider. We store off the current location so that
    # they will be redirected here after authorization.
    # then, after the update, we can store the share request.
    # TODO: is there value in keeping track of share requests that fail?

    #auth = current_user.authorizations.where(:provider => provider_name)
    
    new_path = root_path
    auths = Authorization.where(:user_id => current_user.id, :provider => provider_name)
    if auths.nil?
      store_location
      new_path = "/auth/#{provider_name}"
    end
    auth = auths.first

    squeak_link = "http://mapsqueak.heroku.com/squeaks/#{squeak.id}"
    case provider_name
    when 'facebook'
      # how to get the facebook access_token??
      user = Koala::Facebook::API.new(auth.token)
      if user.nil?
        store_location
        # we do this so that find_or_create will make a new authorization with a new token/secret
        sign_out_of 'facebook'
        # note that the callback URL goes to the create method in the session controller
        # which should point us back here when we are done
        new_path = "/auth/facebook"
      end

      picture_url = squeak_map_preview(squeak)
      puts "Google image url: #{picture_url}"

      begin 
      # id = user.put_wall_post("http://mapsqueak.heroku.com/squeaks/#{squeak.id}")# "I just posted to MapSqueak! http://mapsqueak.heroku.com/squeaks/#{squeak.id}")
      # Use google's static map api to get an image for the squeak
      # id = user.put_wall_post("I just posted to MapSqueak!",
      # user.put_connections('me','links', { :name => squeak.text,
        ret = user.put_connections('me',"feed?picture=#{picture_url}", { :name => squeak.text,
                             :description => "I just posted to MapSqueak!",
                             # TODO: this is a Rack app, so get its current host
                             :link => squeak_link,
                             :caption => Time.now < squeak.expires ? "Expires in #{time_ago_in_words(squeak.expires)}" : "Expired #{time_ago_in_words(squeak.expires)} ago.",
                             :description => "Posted on MapSqueak!" #                              :picture => picture_url

                           })
        # puts ret.picture 
     rescue Exception => e
        flash[:error] = "Error: couldn't post to facebook wall"
        $stderr.puts "Error posting squeak:"
        $stderr.puts e.message
        $stderr.puts e.backtrace.join("\n")
        new_path = squeak
     end
    when 'twitter'
      begin 
        Twitter.configure do |config|
          config.consumer_key = 'K1tkT7Jpi3Ujl0Ftv2V1A' # key 
          config.consumer_secret = 'UzXlol9ZoDd5uJzuhJpiEFtT0reBcQdTO8XSLVp1k' # YOUR_CONSUMER_SECRET
          config.oauth_token = auth.token
          config.oauth_token_secret = auth.secret
        end
        Twitter.update("Check this out on MapSqueak: #{squeak_link}")
      rescue Exception => e
        flash[:error] = "Error: couldn't post to twitter"
        $stderr.puts "Error posting squeak:"
        $stderr.puts e.message
        $stderr.puts e.backtrace.join("\n")
        new_path = squeak
      end
    end

    return new_path
  end
  
end
