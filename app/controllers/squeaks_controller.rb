class SqueaksController < ApplicationController
  # this will allow mobile apps to create squeaks
  protect_from_forgery :except => [:create,:edit]
  
  def new
    @squeak = Squeak.new
    @title = "New Squeak"
    @user = current_user || anonymous_user
  end

  def create
    # I much prefer working with Time objects ... but they don't seem to give the right year and month in the db
    # TODO: truncate the text to 140
    @squeak = Squeak.new(params[:squeak])
    @title = "Create Squeak"
    user = current_user || anonymous_user
    @squeak.user_email = user.email

    # @squeak.time_utc = 0.hours.ago
    # @squeak.expires = params[:squeak][:duration].to_f.hours.from_now
    @squeak.time_utc = DateTime.now.utc
    @squeak.expires = DateTime.now.utc + (params[:squeak][:duration].to_f / 24.0)

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
        # make sure that the json has the id of the squeak so the user gets
        # the id in return, and can update facebook/google+ accordingly
          render :xml => @squeak.to_xml, :status=>:created
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
    
    # Squeak.all(:conditions => ["expires > ?",DateTime.now.utc])
    all_squeaks = []

    if(params.has_key?(:num_squeaks) and params.has_key?(:center_latitude) and params.has_key?(:center_longitude))
      num_squeaks = params[:num_squeaks].to_i
      center_lat = params[:center_latitude].to_f
      center_long = params[:center_longitude].to_f
      
      # all_squeaks = Squeak.where(["expires > ?",DateTime.now.utc]).
      
      # make a bounding box to make the query quicker. 5 degrees in all directions should do the trick
      all_squeaks = Squeak.where(["expires > ?",DateTime.now.utc - 1]).where(:latitude => (center_lat - 5 .. center_lat + 5),:longitude => (center_long - 5 .. center_long + 5))  
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
      @json = @squeaks.to_gmaps4rails
      format.json do

        render :json => @json
        #render :json => squeaks
      end
      format.html do
        @json
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
    if @squeak and @squeak.user_email == user.email

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
      err = "No squeak with that id was created by #{user.email}"
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

  :private

  def show_squeak(params, page_title)
    # I'm commenting this out so that anyone can view anybody's squeak by id (not by user name)
    # user = current_user || anonymous_user
    @squeak = Squeak.find(params[:id])
    respond_to do |format|

      if @squeak # and @squeak.user_email == user.email
        @squeak.text.gsub!(/[\n\r]+/,' ')
        @json = @squeak.to_gmaps4rails
        format.html do
          @title = page_title
          @zoom = 14 # TODO: make this configurable
          #@squeak
          #@json
        end
        format.json do
          render :json => @json
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
       end
    end
  end
end
