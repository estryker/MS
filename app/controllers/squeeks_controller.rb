class SqueeksController < ApplicationController
  def new
    @squeek = Squeek.new
    @title = "New Squeek"
    @user = current_user || anonymous_user
  end

  def create
    # I much prefer working with Time objects ... but they don't seem to give the right year and month in the db
    @squeek = Squeek.new(params[:squeek])
    @title = "Create Squeek"
    user = current_user || anonymous_user
    @squeek.user_email = user.email

    @squeek.time_utc = 0.hours.ago
    @squeek.expires = params[:squeek][:duration].to_f.hours.from_now
    if params.has_key?(:address) and not (params[:address].nil? or params[:address].empty?)
      geo = Geokit::Geocoders::GoogleGeocoder.geocode(params[:address])
      if geo.success?
      @squeek.latitude = geo.lat
      @squeek.longitude = geo.lng
      else
      flash[:error] = "Bad Address format: \'#{params[:address]}\'"
      end
    else
    
    @squeek.latitude = params[:latitude] if params.has_key? :latitude
    @squeek.longitude = params[:longitude] if params.has_key? :longitude
    end

    respond_to do | format |
      if(@squeek.save)
        format.html do
          flash[:success] = "Squeek created"
          # old way is to just call: redirect_to(@squeek)
          @squeek
          @zoom = 14
          # here the json holds the markers
          @json = @squeek.to_gmaps4rails
          render(:action=> :edit)
        end
        format.json do
        # make sure that the json has the id of the squeek so the user gets
        # the id in return, and can update facebook/google+ accordingly
          render :json => @squeek.to_json, :status=>:created, :location=>@squeek
        end
        format.xml do
        # make sure that the json has the id of the squeek so the user gets
        # the id in return, and can update facebook/google+ accordingly
          render :xml => @squeek.to_xml, :status=>:created
        end
      else
        err = "Couldn't create squeek"
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
    # TODO make sure the box is a reasonable size so we don't kill our DB getting too many squeeks
    #min_lat = params[:min_lat].to_i
    #max_lat = params[:max_lat].to_i
    #min_long = params[:min_long].to_i
    #min_long = params[:max_long].to_i
    
    num_squeeks = (params[:num_squeeks] || 1000).to_i
    center_lat = (params[:center_latitude] || 0).to_f
    center_long = (params[:center_longitude] || 0).to_f
    
    all_squeeks = Squeek.all(:conditions => ["expires > ?",DateTime.now.utc])
    all_squeeks.sort! do |a,b| 
      ((a.latitude - center_lat)**2 + (a.longitude - center_long)**2) <=> ((b.latitude - center_lat)**2 + (b.longitude - center_long)**2)
    end
    squeeks = all_squeeks.first(num_squeeks)
    respond_to do |format|
      @json = squeeks.to_gmaps4rails
      format.json do
        render :json => @json
        #render :json => squeeks
      end
      format.html do
        @json
      end
      format.xml do 
        # to minimize the XML:  (but this will effect the index as well ...)
        # render :partial => squeeks
        render :xml => squeeks
      end
    end
  end

  def show
    show_squeek(params,"Show Squeek")
  end

  def edit
    show_squeek(params,"Edit Squeek")
  end

  def update
    user = current_user || anonymous_user
    @squeek = Squeek.find(params[:id])
    @title = "Update Squeek id #{@squeek.id}"
    if @squeek and @squeek.user_email == user.email

      @squeek.latitude = params[:squeek][:latitude]
      @squeek.longitude = params[:squeek][:longitude]
      respond_to do | format |
        if(@squeek.save)
          format.html do
            flash[:success] = "Squeek updated"
            #redirect_to(@squeek)
            redirect_to :action => 'show'
          end
          format.json do
          # make sure that the json has the id of the squeek so the user gets
          # the id in return, and can update facebook/google+ accordingly
            render :json => @squeek, :status=>:updated, :location=>@squeek
          end
        else
          err = "Couldn't update squeek"
          format.html do
            redirect_to :action => :edit
          end
          format.json do
            render :json => {:error => err}.to_json
          end
        end
      end
    else
      err = "No squeek with that id was created by #{user.email}"
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

  def show_squeek(params, page_title)
    user = current_user || anonymous_user
    @squeek = Squeek.find(params[:id])
    respond_to do |format|

      if @squeek and @squeek.user_email == user.email
        @json = @squeek.to_gmaps4rails
        format.html do
          @title = page_title
          @zoom = 14 # TODO: make this configurable
          #@squeek
          #@json
        end
        format.json do
          render :json => @json
        end
        format.xml do 
          render :xml => @squeek
        end
      else
        err = "No squeek by that id is found for #{user.email}"
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
