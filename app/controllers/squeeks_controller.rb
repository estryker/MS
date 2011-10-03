class SqueeksController < ApplicationController
  
  def new
    @squeek = Squeek.new
    @title = "New Squeek"
    @user = current_user || anonymous_user
  end
  
  def create
    now = DateTime.now.utc
    # I much prefer working with Time objects ... but they don't seem to give the right year and month in the db
 
    info = params[:squeek].dup
    info.merge!({:time_utc=>now, :expires=>now + params[:duration].to_i / 24.0})
    
     
    # TODO: jQuery will attempt to get the user's location
    info[:latitude] = params[:latitude] if params.has_key? :latitude
    info[:longitude] = params[:longitude] if params.has_key? :longitude
    
    user = current_user || anonymous_user
    info[:user_email] = user.email 
       
    @squeek = Squeek.new(info)
    
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
        format.html { render 'new' }
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
