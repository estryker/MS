class SqueaksController < ApplicationController
  def new
    @squeak = Squeak.new
    @title = "New Squeak"
    @user = current_user || anonymous_user
  end

  def create
    # I much prefer working with Time objects ... but they don't seem to give the right year and month in the db
    @squeak = Squeak.new(params[:squeak])
    @title = "Create Squeak"
    user = current_user || anonymous_user
    @squeak.user_email = user.email

    @squeak.time_utc = 0.hours.ago
    @squeak.expires = params[:squeak][:duration].to_f.hours.from_now

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
    # TODO make sure the box is a reasonable size so we don't kill our DB getting too many squeaks
    #min_lat = params[:min_lat].to_i
    #max_lat = params[:max_lat].to_i
    #min_long = params[:min_long].to_i
    #min_long = params[:max_long].to_i
    
    num_squeaks = (params[:num_squeaks] || 1000).to_i
    center_lat = (params[:center_latitude] || 0).to_f
    center_long = (params[:center_longitude] || 0).to_f
    
    all_squeaks = Squeak.all(:conditions => ["expires > ?",DateTime.now.utc])
    all_squeaks.sort! do |a,b| 
      ((a.latitude - center_lat)**2 + (a.longitude - center_long)**2) <=> ((b.latitude - center_lat)**2 + (b.longitude - center_long)**2)
    end
    squeaks = all_squeaks.first(num_squeaks)
    respond_to do |format|
      @json = squeaks.to_gmaps4rails
      format.json do
        render :json => @json
        #render :json => squeaks
      end
      format.html do
        @json
      end
      format.xml do 
        # to minimize the XML:  (but this will effect the index as well ...)
        # render :partial => squeaks
        render :xml => squeaks
      end
    end
  end

  def show
    show_squeak(params,"Show Squeak")
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
    user = current_user || anonymous_user
    @squeak = Squeak.find(params[:id])
    respond_to do |format|

      if @squeak and @squeak.user_email == user.email
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
          render :xml => @squeak
        end
      else
        err = "No squeak by that id is found for #{user.email}"
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
