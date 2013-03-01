class SqueaksController < ApplicationController
  # this will allow mobile apps to create squeaks
  protect_from_forgery :except => [:create,:edit]

  include ApplicationHelper
  
  def new
    @squeak = Squeak.new
    @title = "New Squeak"
    @user = current_user  || anonymous_user
  end

  def search
    @squeaks = nil
    per_page = 10
    if params[:search_term] =~ /^[0-9]+$/
      @squeaks = Squeak.where(["id = ?",params[:search_term]]).order("created_at DESC").paginate(:page => params[:page], :per_page => per_page)
    else
      term = '%' + params[:search_term].downcase + '%'
      @squeaks = Squeak.where(["lower(text) like ? ",term]).order("created_at DESC").paginate(:page => params[:page], :per_page => per_page)
    end
    # @num_squeaks = squeaks.length
    # @squeaks = squeaks.order("created_at DESC").paginate(:page => params[:page]) unless squeaks.nil?

    respond_to do | format |
      format.json {render :json=> @squeaks}
      format.xml {render :xml=> @squeaks}
      format.html {render 'list'}
    end 
  end

  def create
    return unless authenticate_squeak?(params,nil,:new)

    # TODO: determine if we need to store these
    params[:squeak].delete :salt
    params[:squeak].delete :hash
   
    # I much prefer working with Time objects ... but they don't seem to give the right year and month in the db
    # TODO: truncate the text to 140
    if params[:squeak].has_key? :encoded_image
      params[:squeak][:image] = Base64.decode64(params[:squeak][:encoded_image])
      params[:squeak].delete(:encoded_image)
    elsif params.has_key? :image_file
      params[:squeak][:image] = params[:image_file].read
    end

    # if we don't have a source, it is a 'user' squeak to help handle old clients
    params[:squeak][:source] ||= 'user'
    
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
    # TODO: verify that the time_utc gets parsed correctly

    # puts "params: #{params[:squeak].inspect}"
    # puts "before time_utc check:  #{@squeak.time_utc} (#{@squeak.time_utc.class})"

    ## Note: params get auto parsed into ActiveSupport::TimeWithZone objects
    ## We have been using DateTime objects.  We need to be careful here. 
    ## I'm sticking with DateTime objects b/c I've had some strange behaviors with heroku

    unless params[:squeak].has_key?(:time_utc)
      now = DateTime.now.utc
      @squeak.time_utc = now
    end
    # puts "after time_utc check: #{@squeak.time_utc} (#{@squeak.time_utc.class})"

    @squeak.expires = @squeak.time_utc.to_datetime + (params[:squeak][:duration].to_f / 24.0)
    # old_way = DateTime.now.utc  + (params[:squeak][:duration].to_f / 24.0)
    # puts "expires: #{@squeak.expires} (#{@squeak.expires.class}) vs #{old_way} (#{old_way.class})"
    
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
    num_squeaks = 10000
    center_lat = 0.0
    center_long = 0.0
    # 1 degree latitude = 110.574km at 0 degrees to  111.69km at 90 degrees
    # 1 degree longitude = 111.320 km at 0 degrees, 78.847 km at 45 degrees, 28.902 km at 75 degrees
    box_size = 2
    if params.has_key? :box_size
      z = params[:box_size].to_f
      if z > 0.0 and z <= 90
        box_size = z 
      end
    end
    #include_relics = [yes|no, on|off]
    #created_since = [date - what format?  ddmmyymmss?, what timezone?  do we store all squeaks in GMT/UTC?]
    #sources=[squeaks | publicfeeds | all etc]
    num_days_for_relics = 1
    if params.has_key? :include_relics and params[:include_relics].downcase.strip == 'no'
      num_days_for_relics = 0
    end
      
    # By default, only return squeaks that have been created in the last year. 
    created_since = DateTime.now.utc - 365
    if params.has_key? :created_since
      created_since = DateTime.parse(params[:created_since]).utc
    end

    sources = []
    if params.has_key? :sources
      sources = params[:sources].split(',')
    end

    categories = []
    if params.has_key? :categories
      categories = params[:categories].split(',')
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
      lower_lat = ((center_lat + 90 - box_size) % 180) - 90
      upper_lat =  ((center_lat + 90 + box_size) %180) - 90
      lower_long = ((center_long + 180 - box_size) % 360) - 180
      upper_long = ((center_long + 180 + box_size) % 360) - 180
      # make a bounding box to make the query quicker. 5 degrees in all directions should do the trick

      where_statement = "created_at > ? AND time_utc <= ? AND expires > ? AND latitude > ? AND latitude < ? AND longitude > ? AND longitude < ?"
      where_items = [created_since, DateTime.now.utc, DateTime.now.utc - num_days_for_relics,lower_lat,upper_lat,lower_long,upper_long]

      # note: we're adding an empty source string to return squeaks with an empty source
      source_string = sources.map {|s| "source = '#{s}'"}.join(' OR ')
      category_string = categories.map {|c| "category = '#{c}'"}.join(' OR ')

      unless source_string.nil? or source_string.empty?
        where_statement += " AND (" + source_string + " OR SOURCE IS NULL)"
      end

      unless category_string.nil? or category_string.empty?
        where_statement += " AND (" + category_string + ")"
      end

      where_clause = [where_statement] + where_items # no need for this: + sources + categories
      # puts where_clause
      all_squeaks = Squeak.where(where_clause)

      # This won't wrap around correctly:
      # .where(:latitude => (lower_lat .. upper_lat),:longitude => (lower_long  .. upper_long))  
    else  
      # this will happen on the web client. I don't care about performance on it right now
      all_squeaks = Squeak.where(["created_at > ? AND time_utc <= ? AND expires > ?",created_since, DateTime.now.utc, DateTime.now.utc]) 
    end
    
    # Inplace sorting was working up until the call to 'first' during debugging. I have no idea why. 
    sorted_squeaks = all_squeaks.sort do |a,b| 
      ((a.latitude - center_lat)**2 + (a.longitude - center_long)**2) <=> ((b.latitude - center_lat)**2 + (b.longitude - center_long)**2)
    end

    #puts sorted_squeaks.map {|s| s.id.to_s}.join(' ')
    #puts sorted_squeaks.first(num_squeaks).map {|s| s.id.to_s}.join(' ')
    
    # trim by distance first, then sort by id
    # note that gmaps4rails doesn't like newlines in the description
    # debug: @squeaks = sorted_squeaks.first(num_squeaks).each {|s| s.text.gsub!(/[\n\r]+/,' ')}    
    @squeaks = sorted_squeaks.first(num_squeaks).sort {|a,b| a.id <=> b.id}.each {|s| s.text.gsub!(/[\n\r]+/,' ')}

    respond_to do |format|
      format.json do

        render :json => @squeaks
        #render :json => squeaks
      end
      format.html do
        @json = @squeaks.to_gmaps4rails
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
    if @squeak and (@squeak.user_id == user.id || user.admin?)

      return unless authenticate_squeak?(params,@squeak,:edit)
      @squeak.latitude = params[:squeak][:latitude]
      @squeak.longitude = params[:squeak][:longitude]
      @squeak.text = params[:squeak][:text]
      @squeak.expires = DateTime.parse(params[:squeak][:expires])
      @squeak.category = params[:squeak][:category]
      @squeak.source = params[:squeak][:source]
      @squeak.timezone = params[:squeak][:timezone]

      # puts "source: " + params[:squeak][:source]

      if user.admin?
        @squeak.disable_expires_validation = true
      end
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
  
          format.xml do
            # TODO: why was I doing this ??
            # render :xml => @squeak.to_xml, :status=>:created
            render :partial => @squeak
          end
        else
          # TODO: log this! puts ' error updating squeak' + @squeak.errors.full_messages.join("\n")
          err = "Couldn't update squeak"
          format.html do
            #redirect_to :action => :edit
            render 'edit'
          end
          format.json do
            render :json => {:error => err}.to_json
          end
          format.xml do
            render :xml => {:error => err, :status =>:unprocessable_entity}
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
        format.xml do
          render :xml => {:error => err, :status =>:unprocessable_entity}
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

    uri = URI("http://dev.openstreetmap.org/")
    http = Net::HTTP.start(uri.host, uri.port)

    # uri = URI("http://maps.googleapis.com/")
    # http = Net::HTTP.start(uri.host, uri.port)
    # e.g. http://maps.googleapis.com/maps/api/staticmap?center=54.1,-1.7&zoom=13&size=200x200&maptype=roadmap&markers=icon:http://mapsqueak.heroku.com/images/old_squeak_marker.png%7C54.1,-1.7&sensor=true

    #if params.has_key? :format
    #  format = params[:format]
    #end
    # map_string =  "/maps/api/staticmap?center=#{squeak.latitude},#{squeak.longitude}&zoom=13&size=200x200&maptype=roadmap&markers=icon:#{icon_url}%7C#{squeak.latitude},#{squeak.longitude}&format=#{format}&sensor=true"

    # map_string = "/~pafciu17/?module=map&center=#{squeak.longitude},#{squeak.latitude}&width=200&height=200&zoom=14&points=#{squeak.longitude},#{squeak.latitude}&pointImageUrl=#{icon_url}"
    uri = URI("http://open.mapquestapi.com/")
    http = Net::HTTP.start(uri.host, uri.port)
    format = "png"

    lat_shift = 0.0
    long_shift = 0.0
    unless squeak.image.nil?
      # uncenter the marker to put in the upper left corner to make room for image
      # on twitter posts
      lat_shift = 0.001
      long_shift = 0.002
    end
    map_string = "/staticmap/v4/getmap?center=#{squeak.latitude - lat_shift},#{squeak.longitude + long_shift}&zoom=15&size=200,200&type=map&imagetype=#{format}&xis=#{icon_url},1,C,#{squeak.latitude},#{squeak.longitude}"

    send_data http.get(map_string).body, :type => "image/#{format}", :disposition => 'inline'
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

    format = "png"
    if params.has_key? :format
      format = params[:format]
    end

    # google maps api
    # redirect_to "http://maps.googleapis.com/maps/api/staticmap?center=#{squeak.latitude},#{squeak.longitude}&zoom=13&size=200x200&maptype=roadmap&markers=icon:#{icon_url}%7C#{squeak.latitude},#{squeak.longitude}&format=#{format}&sensor=true"

    #box_low = "#{squeak.longitude - 0.25},#{squeak.latitude - 0.25}"
    #box_high = "#{squeak.longitude + 0.25},#{squeak.latitude + 0.25},"

    # open stretmap api
    # e.g. http://pafciu17.dev.openstreetmap.org/?module=map&bbox=-77.123299,38.918027,-76.623299,39.418027&width=200&points=-76.873299,39.168027&pointImageUrl=http://mapsqueak.heroku.com/images/new_squeak_marker.png

    # if we want a bounding box (needs tweaking)
    #puts "http://dev.openstreetmap.org/~pafciu17/?module=map&bbox=#{box_low},#{box_high}&width=200&points=#{squeak.longitude},#{squeak.latitude}&pointImageUrl=#{icon_url}"
    #redirect_to "http://dev.openstreetmap.org/~pafciu17/?module=map&bbox=#{box_low},#{box_high}&width=200&points=#{squeak.longitude},#{squeak.latitude}&pointImageUrl=#{icon_url}"
 
    # this is not encouraged by open streetmaps b/c it puts a load on the server
    # redirect_to "http://dev.openstreetmap.org/~pafciu17/?module=map&center=#{squeak.longitude},#{squeak.latitude}&width=200&height=200&zoom=14&points=#{squeak.longitude},#{squeak.latitude}&pointImageUrl=#{icon_url}"

    # but this one doesn't allow for custom icons
    # redirect_to "http://staticmap.openstreetmap.de/staticmap.php?center=#{squeak.longitude},#{squeak.latitude}&zoom=14&size=200x200&maptype=mapnik&markers=#{squeak.longitude},#{squeak.latitude},#{icon_url}" # pipe separate for multiple: lightblue1|40.711614,-74.012318,lightblue2|40.718217,-73.998284,lightblue3"

    # mapquest API
    lat_shift = 0.0
    long_shift = 0.0
    unless squeak.image.nil?
      # uncenter the marker to put in the upper left corner to make room for image
      # on twitter posts
      lat_shift = 0.001
      long_shift = 0.002
    end
    redirect_to "http://open.mapquestapi.com/staticmap/v4/getmap?center=#{squeak.latitude - lat_shift},#{squeak.longitude + long_shift}&zoom=15&size=200,200&type=map&imagetype=#{format}&xis=#{icon_url},1,C,#{squeak.latitude},#{squeak.longitude}"
  end

  def squeak_image
    squeak = Squeak.find(params[:id])

    if params.has_key? :format
      
      if params[:format] =~ /jpe?g/i  
        send_data squeak.image, :type => "image/jpeg", :disposition => 'inline' # @squeak_image = squeak.image

      elsif params[:format] =~ /xml/i 
        @id = squeak.id
        @encoded_squeak_image = Base64.encode64(image)
        render :partial => "squeak_image"
      end
    end
  end
  
  :private

  def authenticate_squeak?(params,current_squeak,fail_page)
    # for authentication
    if params[:squeak].has_key? :salt and params[:squeak].has_key? :hash
      key = "OIA9cj6nTfiV4EHkfDZc2A" # test
      hmac = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('md5'),key,params[:squeak][:salt])).strip
      if hmac == params[:squeak][:hash].strip
        # puts "HMAC correct \'#{hmac}\'"
        return true
      else
        puts "No HMAC match: \'#{hmac}\' vs received: \'#{params[:squeak][:hash]}\'"
        err = "Couldn't create squeak: Incorrect HMAC received"
        respond_to do | format |
          format.html do
            @squeak = Squeak.new if current_squeak.nil?
            render fail_page
          end
          format.json do
            render :json => {:error => err}.to_json, :status =>:unprocessable_entity
          end
          format.xml do
            render :xml => {:error => err, :status =>:unprocessable_entity}
          end
        end
        return false
      end
    else
      puts "No HMAC received"
      err = "Couldn't create squeak: No HMAC received"
      respond_to do | format |
        format.html do
          @squeak = Squeak.new
          render fail_page
        end
        
        format.json do
          render :json => {:error => err}.to_json, :status =>:unprocessable_entity
        end
        format.xml do
          render :xml => {:error => err, :status =>:unprocessable_entity}
        end
      end
      return false
    end
  end

  def show_squeak(params, page_title)
    # I'm commenting this out so that anyone can view anybody's squeak by id (not by user name)
    # user = current_user || anonymous_user
    @squeak = Squeak.find(params[:id])

    respond_to do |format|

      if @squeak # and @squeak.user_email == user.email
        @squeak.text.gsub!(/[\n\r]+/,' ')
      
        # TODO: correct the syntax here
        @num_resqueaks = ShareRequest.where({:squeak_id => @squeak.id,:provider => 'mapsqueak'}, {:group => :user_id}).uniq.count
        @num_checks = SqueakCheck.where(:squeak_id => @squeak.id, :checked => true).count
        
        sq = SqueakCheck.where(:squeak_id => @squeak.id,:user_id => (current_user || anonymous_user).id)
        if sq.nil? or sq.empty?
          @checked_by_user = nil
        else
          @squeak_check = sq.first
          @checked_by_user = @squeak_check.checked
        end

        format.html do
          @title = page_title
          @zoom = 14 # TODO: make this configurable
          # TODO: add this to the database so we don't need to  know the context of where we are.
          @squeak_map_link = "#{root_url}squeaks/map_preview/#{@squeak.id}.jpg"
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

  def proper_home
    redirect_to 'http://www.mapsqueak.com/'
  end
end
