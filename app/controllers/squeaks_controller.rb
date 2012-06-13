class SqueaksController < ApplicationController
  # this will allow mobile apps to create squeaks
  protect_from_forgery :except => [:create,:edit]

  include ApplicationHelper
  
  def new
    @squeak = Squeak.new
    @title = "New Squeak"
    @user = current_user  || anonymous_user
  end

  def create
    # I much prefer working with Time objects ... but they don't seem to give the right year and month in the db
    # TODO: truncate the text to 140
    if params[:squeak].has_key? :encoded_image
      params[:squeak][:image] = Base64.decode64(params[:squeak][:encoded_image])
      params[:squeak].delete(:encoded_image)
    elsif params.has_key? :image_file
      params[:squeak][:image] = params[:image_file].read
    end

    # For now, we're just logging
    if params[:squeak].has_key? :salt and params[:squeak].has_key? :hash
      key = "test"
      hmac = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('md5'),key,params[:squeak][:salt]))
      if hmac == params[:squeak][:hash]
        puts "HMAC correct"
      else
        puts "No HMAC match: #{hmac} vs received: #{params[:squeak][:hash]}"
      end
      
      # TODO: determine if we need to store these
      params[:squeak].delete :salt
      params[:squeak].delete :hash
    else
      puts "No HMAC received"
    end

    @squeak = Squeak.new(params[:squeak])
    @title = "Create Squeak"
    user = current_user  || anonymous_user
    @squeak.user_id = user.id

    if params.has_key?(:address) and not (params[:address].nil? or params[:address].empty?)
      geo = Geokit::Geocoders::GoogleGeocoder.geocode(params[:address])
      if geo.success?
      @squeak.latitude = geo.lat
      @squeak.longitude = geo.lng
      else
      flash[:error] = "Bad Address format: \'#{params[:address]}\'"
      end
    else
    
    @squeak.latitude = params[:latitude] if params.has_key? :latitude
    @squeak.longitude = params[:longitude] if params.has_key? :longitude
    end

    # @squeak.time_utc = 0.hours.ago
    # @squeak.expires = params[:squeak][:duration].to_f.hours.from_now
    now = DateTime.now.utc
    @squeak.time_utc = now
    @squeak.expires = now + (params[:squeak][:duration].to_f / 24.0)

    respond_to do | format |
      if(@squeak.save)
        format.html do
          flash[:success] = "Squeak created"
          # old way is to just call: redirect_to(@squeak)
          @squeak
          @zoom = 14
          # here the json holds the markers
          @json = @squeak.to_gmaps4rails
          render(:action=> :edit)
        end
        format.json do
        # make sure that the json has the id of the squeak so the user gets
        # the id in return, and can update facebook/google+ accordingly
          render :json => @squeak.to_json, :status=>:created, :location=>@squeak
        end
        format.xml do
          # TODO: why was I doing this ??
          # render :xml => @squeak.to_xml, :status=>:created
          render :partial => @squeak
        end
      else
        err = "Couldn't create squeak"
        format.html do
          render :new
        end
        
        format.json do
           render :json => {:error => err}.to_json, :status =>:unprocessable_entity
         end
         format.xml do
           render :xml => {:error => err, :status =>:unprocessable_entity}
         end
      end
    end
  end

  def index
    # TODO: use better defaults? get these from other means?
    num_squeaks = 1000
    center_lat = 0.0
    center_long = 0.0
    zoom_level = 5 
    if params.has_key? :zoom_level
      z = params[:zoom_level].to_f
      if z > 0.0 and z <= 90
        zoom_level = z 
      end
    end

    # Squeak.all(:conditions => ["expires > ?",DateTime.now.utc])
    all_squeaks = []

    if(params.has_key?(:num_squeaks) and params.has_key?(:center_latitude) and params.has_key?(:center_longitude))
      num_squeaks = params[:num_squeaks].to_i
      center_lat = params[:center_latitude].to_f
      center_long = params[:center_longitude].to_f
      
      # all_squeaks = Squeak.where(["expires > ?",DateTime.now.utc]).

      # shift the numbers up to be between 0-180 and 0-360 so we can use modular arithmetic to
      # work at the edges. 
      lower_lat = ((center_lat + 90 - zoom_level) % 180) - 90
      upper_lat =  ((center_lat + 90 + zoom_level) %180) - 90
      lower_long = ((center_long + 180 - zoom_level) % 360) - 180
      upper_long = ((center_long + 180 + zoom_level) % 360) - 180
      # make a bounding box to make the query quicker. 5 degrees in all directions should do the trick
      all_squeaks = Squeak.where(["expires > ? AND latitude > ? AND latitude < ? AND longitude > ? AND longitude < ?",
                                  DateTime.now.utc - 1,lower_lat,upper_lat,lower_long,upper_long])

      # This won't wrap around correctly:
      # .where(:latitude => (lower_lat .. upper_lat),:longitude => (lower_long  .. upper_long))  
    else  
      # this will happen on the web client. I don't care about performance on it right now
      all_squeaks = Squeak.where(["expires > ?",DateTime.now.utc]) 
    end
    
    all_squeaks.sort! do |a,b| 
      ((a.latitude - center_lat)**2 + (a.longitude - center_long)**2) <=> ((b.latitude - center_lat)**2 + (b.longitude - center_long)**2)
    end
    #@squeaks = all_squeaks.first(num_squeaks)
    # note that gmaps4rails doesn't like newlines in the description
    @squeaks = all_squeaks.first(num_squeaks).each {|s| s.text.gsub!(/[\n\r]+/,' ')}
    respond_to do |format|
      format.json do

        render :json => @squeaks
        #render :json => squeaks
      end
      format.html do
        @json = @squeak.to_gmaps4rails
      end
      format.xml do 
        # to minimize the XML
        render :template => 'squeaks/index.xml.builder'
        # use this to get full xml representation
        #render :xml => @squeaks
      end
    end
  end

  def show
    show_squeak(params,"Squeak Details")
  end

  def edit
    show_squeak(params,"Edit Squeak")
  end

  def update
    user = current_user || anonymous_user
    @squeak = Squeak.find(params[:id])
    @title = "Update Squeak id #{@squeak.id}"
    if @squeak and @squeak.user_id == user.id

      @squeak.latitude = params[:squeak][:latitude]
      @squeak.longitude = params[:squeak][:longitude]
      respond_to do | format |
        if(@squeak.save)
          format.html do
            flash[:success] = "Squeak updated"
            #redirect_to(@squeak)
            redirect_to :action => 'show'
          end
          format.json do
          # make sure that the json has the id of the squeak so the user gets
          # the id in return, and can update facebook/google+ accordingly
            render :json => @squeak, :status=>:updated, :location=>@squeak
          end
        else
          err = "Couldn't update squeak"
          format.html do
            redirect_to :action => :edit
          end
          format.json do
            render :json => {:error => err}.to_json
          end
        end
      end
    else
      err = "No squeak with that id was created by #{user.name}"
      respond_to do | format |
        format.html do 
          flash[:error] = err
          redirect_to current_user
        end
        format.json do 
          render :json => {:error => err}.to_json
        end
      end
    end
  end

  def map_image
    squeak = Squeak.find(params[:id])
    icon_url = "#{root_url}images/new_squeak_marker.png"
    if squeak.created_at < 5.minutes.ago
      # use the green icon for older squeaks
      icon_url = "#{root_url}images/old_squeak_marker.png"
    end
    uri = URI("http://maps.googleapis.com/")
    http = Net::HTTP.start(uri.host, uri.port)
    # e.g. http://maps.googleapis.com/maps/api/staticmap?center=54.1,-1.7&zoom=13&size=200x200&maptype=roadmap&markers=icon:http://mapsqueak.heroku.com/images/old_squeak_marker.png%7C54.1,-1.7&sensor=true
    map_string = "/maps/api/staticmap?center=#{squeak.latitude},#{squeak.longitude}&zoom=13&size=400x300&maptype=roadmap&markers=icon:#{icon_url}%7C#{squeak.latitude},#{squeak.longitude}&format=jpg&sensor=true"

    send_data http.get(map_string).body
  end

  def map_preview
    squeak = Squeak.find(params[:id])
    #    redirect_to "http://maps.googleapis.com/maps/api/staticmap?center=#{squeak.latitude},#{squeak.longitude}&zoom=13&size=200x200&maptype=roadmap&markers=color:blue%7Clabel:M%7C#{squeak.latitude},#{squeak.longitude}%7C&sensor=true" # icon:#{root_url}images/new_squeak_marker.png
    icon_url = "#{root_url}images/new_squeak_marker.png"
    if squeak.created_at < 5.minutes.ago
      # use the green icon for older squeaks
      icon_url = "#{root_url}images/old_squeak_marker.png"
    end

    # If we ever wanted to store the image, this could work:
    # uri = URI("http://maps.googleapis.com/")
    # http = Net::HTTP.start(uri.host, uri.port)
    # map_string = "/maps/api/staticmap?center=#{squeak.latitude},#{squeak.longitude}&zoom=13&size=200x200&maptype=roadmap&markers=color:blue%7Cicon:#{icon_url}%7C#{squeak.latitude},#{squeak.longitude}%7C&sensor=true"
    
    # e.g. http://maps.googleapis.com/maps/api/staticmap?center=54.1,-1.7&zoom=13&size=200x200&maptype=roadmap&markers=icon:http://mapsqueak.heroku.com/images/old_squeak_marker.png%7C54.1,-1.7&sensor=true
    # http.get(map_string).body

    redirect_to "http://maps.googleapis.com/maps/api/staticmap?center=#{squeak.latitude},#{squeak.longitude}&zoom=13&size=200x200&maptype=roadmap&markers=color:blue%7Cicon:#{icon_url}%7C#{squeak.latitude},#{squeak.longitude}%7C&sensor=true"
  end

  def squeak_image
    squeak = Squeak.find(params[:id])
    respond_to do | format |
      format.html do 
        send_data squeak.image, :disposition => 'inline' # @squeak_image = squeak.image
      end
      format.xml do 
        @id = squeak.id
        @encoded_squeak_image = Base64.encode64(squeak.image)
        render :partial => "squeak_image"
      end
    end
  end

  :private

  def show_squeak(params, page_title)
    # I'm commenting this out so that anyone can view anybody's squeak by id (not by user name)
    # user = current_user || anonymous_user
    @squeak = Squeak.find(params[:id])
    respond_to do |format|

      if @squeak # and @squeak.user_email == user.email
        @squeak.text.gsub!(/[\n\r]+/,' ')
   
        format.html do
          @title = page_title
          @zoom = 14 # TODO: make this configurable
          # TODO: add this to the database so we don't need to  know the context of where we are.
          @squeak_map_preview = squeak_map_preview(@squeak)
          @json = @squeak.to_gmaps4rails
        end
        format.json do
          render :json => @squeak
        end
        format.xml do
          # this returns the entire squeak info. don't need or want all that 
          #render :xml => @squeak
          render :partial => @squeak
        end
      else
        err = "No squeak by that id was found"
        format.html do
          flash[:error] = err
          redirect_to current_user
        end
        format.json do
          render :json => {:error => err}.to_json
        end
        format.xml do 
          #TODO: how to do this appropriately
          render :xml => err
        end
       end
    end
  end
end
