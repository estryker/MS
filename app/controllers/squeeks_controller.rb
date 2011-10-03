class SqueeksController < ApplicationController
  
  def new
    @squeek = Squeek.new
    @title = "New Squeek"
    @user = current_user || anonymous_user
  end
  
  def create
    # I much prefer working with Time objects ... but they don't seem to give the right year and month in the db
    @squeek = Squeek.new(params[:squeek])
    
    user = current_user || anonymous_user
    @squeek.user_email = user.email
       
    @squeek.time_utc = 0.hours.ago
    @squeek.expires = params[:duration].to_i.hours.from_now
    if params.has_key?(:address) and not (params[:address].nil? or params[:address].empty?) 
      geo = Geokit::Geocoders::GoogleGeocoder.geocode(params[:address])
      if geo.success?
        @squeek.latitude = geo.lat
        @squeek.longitude = geo.lng
      else
        flash[:error] = "Bad Address format: \'#{params[:address]}\'"
      end
    else 
      # TODO: jQuery will attempt to get the user's location
      @squeek.latitude = params[:latitude] if params.has_key? :latitude
      @squeek.longitude = params[:longitude] if params.has_key? :longitude
    end
    
    respond_to do | format |
      if(@squeek.save)
        format.html do 
          flash[:success] = "Squeek created"
          redirect_to(@squeek)
        end        
        format.json do
          # make sure that the json has the id of the squeek so the user gets 
          # the id in return, and can update facebook/google+ accordingly
          render :json => @squeek, :status=>:created, :location=>@squeek
        end  
      else
        format.html do
           render :new
         end
        format.json { render :xml =>@squeek.errors, :status =>:unprocessable_entity}
      end
    end  
  end
  
  def index
    respond_to do |format|
     @json = Squeek.all(:conditions => ["expires > ?",DateTime.now.utc]).to_gmaps4rails
     format.json do
        render :json => @json 
       end
       format.html do
        @json
       end
    end
  end
  
  def show
    respond_to do |format|
      @squeek = Squeek.find(params[:id])
      @json = @squeek.to_gmaps4rails
      format.html do 
        # TODO: need more meaningful title
        @title = @squeek.text 
        @zoom = 14 # TODO: make this configurable
        @json
      end
      format.json do
       render :json => @json 
      end
    end
  end
end
