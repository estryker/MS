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
          render :json => @squeek, :status=>:created, :location=>@squeek
        end
      else
        format.html do
          render :new
        end
        #TODO: should this be render :json ??
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
    show_squeek(params,"Show Squeek")
  end

  def edit
    show_squeek(params,"Edit Squeek")
  end

  def update
    user = current_user || anonymous_user
    @squeek = Squeek.find(params[:id])
    @title = "Update Squeek"
    if @squeek and @squeek.user_email == user.email

      @squeek.latitude = params[:latitude]
      @squeek.longitude = params[:longitude]
      respond_to do | format |
        if(@squeek.save)
          format.html do
            flash[:success] = "Squeek updated"
            #redirect_to(@squeek)
            redirect_to root_path
          end
          format.json do
          # make sure that the json has the id of the squeek so the user gets
          # the id in return, and can update facebook/google+ accordingly
            render :json => @squeek, :status=>:created, :location=>@squeek
          end
        else
          err = "Couldn't update squeek"
          format.html do
            flash[:error] = err
            redirect_to(@squeek)
          end
          format.json do
            render :json => "[:error => #{err}]"
          end
        end
      end
    else
    flash[:error] = "No squeek with that id was created by #{user.email}"
    render :edit
    end
  end

  :private

  def show_squeek(params, page_title)
    user = current_user || anonymous_user
    @squeek = Squeek.find(params[:id])
    @title = page_title # e.g. "Show Squeek"
    respond_to do |format|

      if @squeek and @squeek.user_email == user.email
        @json = @squeek.to_gmaps4rails
        format.html do
          @title = @squeek.text
          @zoom = 14 # TODO: make this configurable
          @squeek
          @json
        end
        format.json do
          render :json => @json
        end
      else
        err = "No squeek by that id is found for #{user.email}"
        format.html do
          flash[:error] = err
          redirect_to current_user
        end
        format.json do
          render :json => "[:error => #{err}]"
        end
      end
    end
  end
end
