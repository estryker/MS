class ShareRequestsController < ApplicationController
  require 'net/http'
  Bitly.use_api_version_3
  BitlyShortener = Bitly.new('o_11vp9b9mda', 'R_5b7f47f7cf4b8281ce82e10ae324a5c6')

  # so the mobile app can create a session
  protect_from_forgery :except => [:create]
  
  include ActionView::Helpers::DateHelper
  include ApplicationHelper

  def create
    # we expect params to have :squeak_id and :provider. We will determine the :user_id of the requester
    squeak = Squeak.find(params[:squeak_id])
    user = current_user || anonymous_user
    if squeak.nil?
      # throw an appropriate error and redirect to the index_path
      respond_to_user("Can't find squeak with id of #{params[:squeak_id]}",1,index_path)
    else
      if params[:provider] == 'mapsqueak'
        share_request = ShareRequest.new({:user_id => user.id,:squeak_id => squeak.id,:provider=>'mapsqueak'})
        # create a copy of the squeak if resqueaked? want to give the original the most credit, but want these to show up on the user's profile. 
        if share_request.save 
          # TODO: consider deferring most of this to the squeaks_controller create method. except
          # we'd have to deal with the image issue, and hash/salt issue. Pick your poison
          squeak_time = DateTime.now.utc
          curr_duration = (squeak.expires - 0.hours.ago).to_f / 1.hour
          role_id =  user.role_id
          max_duration = Role.find(role_id).max_squeak_duration

          duration = 1
          if curr_duration > max_duration 
            duration = max_duration
          elsif curr_duration > 0
            duration = curr_duration
          end

          expires = squeak_time + (duration.to_f / 24.0)
          resqueak = Squeak.new(:latitude => squeak.latitude, :longitude => squeak.longitude, 
                                :time_utc => squeak_time, :expires => expires,
                                :source => squeak.source,:category => squeak.category,:user_id => user.id,
                                :text => squeak.text, :duration => duration, :timezone => squeak.timezone,
                                :image => squeak.image )
          if resqueak.save
            respond_to_user("Squeak successfully resqueaked. Edit as necessary.",0,edit_squeak_path(resqueak.id))
          else
            err_msg = resqueak.errors.map {|attr,msg| "#{attr} - #{msg}"}.join(' ')
            respond_to_user("Couldn't resqueak: #{err_msg}",1,squeak)
          end
        else
          err_msg = share_request.errors.map {|attr,msg| "#{attr} - #{msg}"}.join(' ')
          respond_to_user("Couldn't save share request: #{err_msg}",1,squeak)
        end

      elsif signed_in_to?(params[:provider]) 
        #request = ShareRequest.new(params.merge({:user_id => current_user.id}))
        share_request = ShareRequest.new({:user_id => current_user.id,:squeak_id => params[:squeak_id],:provider=>params[:provider]})

        # first save to the database, then actually do the share
        # TODO: update a 'confirmed_update' parameter in the share request
        if share_request.save
          begin
            redirect_path = share(squeak,params[:provider])

            respond_to_user("Squeak successfully shared on #{params[:provider]}",0,redirect_path)
          rescue Exception => e
            respond_to_user("Couldn't complete share request to #{params[:provider]} : #{e.message}",1,squeak)
          end
        else
          err_msg = share_request.errors.map {|attr,msg| "#{attr} - #{msg}"}.join(' ')
          respond_to_user("Couldn't save share request: #{err_msg}",1,squeak)
        end
      else
        #format.html do 
        respond_to_user("User must signin to #{params[:provider]} to share on #{params[:provider]}",1,signin_path)
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

    new_path = index_path
    auths = Authorization.where(:user_id => current_user.id, :provider => provider_name)
    
    auth = nil
    # we need a token for both services. If we add a service that doesn't use a token, then
    # we'll have to move the check for a non-nil token elsewhere
    if auths.nil? or auths.empty? or auths.first.token.nil?
      store_location
      # new_path = "/auth/#{provider_name}"
      raise Exception.new("Missing authentication tokens. Suggest user sign out and sign in to #{provider_name} again.")
    else
      auth = auths.first
    end
    
    squeak_link = "http://mapsqueak.heroku.com/squeaks/#{squeak.id}"

    # TODO: if the squeak has an image, use that instead
    picture_url = squeak_map_preview(squeak)

    link = "http://www.mapsqueak.com/squeak.php?id=#{squeak.id}"
    squeak_link = link
    # **Removing the bit.ly shortener for squeak sharing for simplification purposes. 
    #begin 
    #  squeak_link = BitlyShortener.shorten(link).short_url
    #rescue Exception => e
    #  puts e.message + ' ' + e.backtrace.join("\n")
    #end

    case provider_name
    when 'facebook'
      user = Koala::Facebook::API.new(auth.token)
      
      if user.nil?
        store_location
        # we do this so that find_or_create will make a new authorization with a new token/secret
        sign_out_of 'facebook'
        # note that the callback URL goes to the create method in the session controller
        # which should point us back here when we are done
        new_path = "/auth/facebook"
      else
        
        puts "Google image url: #{picture_url}"
        
        begin 
          # user.put_connections('me','links', { :name => squeak.text,
          #  ret = user.put_connections('me',"feed", { :name => squeak.text,
          # debug
          caption = Time.now < squeak.expires ? "Valid for #{time_ago_in_words(squeak.expires)}" : "Expired #{time_ago_in_words(squeak.expires)} ago."
          
          # **We need to add/subtract hours according to the timezone abbreviation. need big chart to do so?
          #display_time = squeak.expires.strftime("%a, %b %d %I:%M %p") + " #{squeak.timezone}"
          #caption = Time.now < squeak.expires ? "Valid until #{display_time} (#{time_ago_in_words(squeak.expires)})" : "Expired at #{display_time} (#{time_ago_in_words(squeak.expires)} ago)."

          #`curl -F 'access_token=#{auth.token}' -F 'message=I just posted to MapSqueak!' -F 'link=http://mapsqueak.heroku.com/squeaks/#{squeak.id}' -F 'caption=#{caption} https://graph.facebook.com/#{auth.uid}/feed`
          facebook_args = { 
            :description => "MapSqueak. Intersecting people, place & time.",
            :link =>  squeak_link, # :link => "#{root_url}squeaks/#{squeak.id}", # 
            :name => squeak.text,
            :caption => caption
          }

          if squeak.image.nil?
            # facebook_args.merge! :picture => "#{root_url}squeaks/map_image/#{squeak.id}.jpg"
          else
            facebook_args.merge! :picture => "#{root_url}squeaks/image/#{squeak.id}.jpg"
          end

          ret = user.put_wall_post(squeak.text, facebook_args)

          # user.get_object(ret["id"]) # to ensure the image gets pulled in?

         rescue Exception => e
          # flash[:error] = "Error: couldn't post to facebook wall"
          puts "Error posting squeak:"
          puts e.message
          puts e.backtrace.join("\n")
          raise e
        end
      end
    when 'twitter'
      begin 
        Twitter.configure do |config|
          config.consumer_key = 'K1tkT7Jpi3Ujl0Ftv2V1A' # key 
          config.consumer_secret = 'UzXlol9ZoDd5uJzuhJpiEFtT0reBcQdTO8XSLVp1k' # YOUR_CONSUMER_SECRET
          config.oauth_token = auth.token || "565418060-8n1fSDtUJguYtrm8A2Vrin5Yu3Yhaqo8agzgvMgY"
          config.oauth_token_secret = auth.secret || "Fe5gczCZg0Av21dpeoBb5YDtezpph1ef0b37gajW8"
        end

        tweet = squeak.text
        if squeak.text.length + squeak_link.length + 1 > 140
          tweet = squeak.text[0 ... (136 - squeak_link.length)] + '... ' + squeak_link
        else
          tweet = squeak.text + ' ' + squeak_link
        end

        # For now, we will only tweet the text - no image. Twitter cards has trouble with the images. 
        #if squeak.image.nil?
        Twitter.update(tweet,{:lat => squeak.latitude,:long => squeak.longitude})
        #else
        #  Twitter.update_with_media(tweet, {'io' => StringIO.new(squeak.image), 'type' => 'jpeg'},{:lat => squeak.latitude,:long => squeak.longitude})
        #end        
      rescue Exception => e
        # flash[:error] = "Error: couldn't post to twitter"
        $stderr.puts "Error posting squeak:"
        $stderr.puts e.message
        $stderr.puts e.backtrace.join("\n")
        raise e
      end
    end
    
    return new_path
  end
  
end
