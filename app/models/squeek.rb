class Squeek < ActiveRecord::Base
 
 ### NOTE: we don't need to do all the gmaps4rails_address junk b/c we already have the lat/long!
 ### Sooooo.... we put :process_geocoding => false to skip that!
 ### here we simply specify the lat/long columns in our database, and put in dummy addresses.
 acts_as_gmappable :lat => 'latitude', :lng => 'longitude', :checker => :prevent_geocoding, 
                  :address => "address", :normalized_address => "address",
                  :process_geocoding => false

  def prevent_geocoding
    address.blank? || (!lat.blank? && !lng.blank?) 
  end
  
  # TODO: consider making it possible to make a squeek by address
  #def gmaps4rails_address
    #describe how to retrieve the address from your model, if you use directly a db column, you can dry your code, see wiki
    #self.text
   # "Pye Lane, Shaw Mills, England"
  #end
  def gmaps4rails_infowindow
    #"<h4>#{name}</h4>" << "<h4>#{address}</h4>"
    self.text
  end
end
