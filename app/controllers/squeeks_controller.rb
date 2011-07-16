class SqueeksController < ApplicationController
  
  def new
    @squeek = Squeek.new
    @title = "New Squeek"
  end
  
  def create
    now = DateTime.now.utc
    # I much prefer working with Time objects ... but they don't seem to give the right year and month in the db
 
    info = params[:squeek].dup
    info.merge!({:time_utc=>now, :expires=>now + params[:duration].to_i / 24.0})
    
    # TODO: jQuery will attempt to get the user's location
    info[:latitude] = params[:latitude] if params.has_key? :latitude
    info[:longitude] = params[:longitude] if params.has_key? :longitude
    
    @squeek = Squeek.new(info)
    
    respond_to do | format |
      if(@squeek.save)
        format.html do 
          flash[:success] = "Squeek created"
          redirect_to root_url
        end        
        format.json do
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
end
