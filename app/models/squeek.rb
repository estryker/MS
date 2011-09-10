class Squeek < ActiveRecord::Base
 belongs_to :user, :primary_key => :user_email
 
 numeric_regex = /^-?[0-9.]+$/
 
 validates :latitude, :presence => true, 
                  :format => {:with => numeric_regex}
                
 validates :longitude, :presence => true,
                      :format => {:with => numeric_regex}
                      
 validates :text, :presence => true,
                  :length       => { :within => 1..140 }
 
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

# == Schema Information
#
# Table name: squeeks
#
#  id         :integer         not null, primary key
#  latitude   :float
#  longitude  :float
#  time_utc   :datetime
#  text       :string(255)
#  expires    :datetime
#  created_at :datetime
#  updated_at :datetime
#  gmaps      :boolean
#  user_email :string(255)
#

