# == Schema Information
#
# Table name: squeaks
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
#  duration   :float
#  user_id    :integer
#  image      :binary
#  timezone   :string(255)
#

class Squeak < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  include ApplicationHelper
  
 belongs_to :user # , :primary_key => :user_email
 
 numeric_regex = /^-?[0-9.]+$/
 
 validates :latitude, :presence => true, 
                  :format => {:with => numeric_regex},
                  :numericality => {:greater_than_or_equal_to => -90,:less_than_or_equal_to => 90}
 validates :longitude, :presence => true,
                      :format => {:with => numeric_regex},
                      :numericality => {:greater_than_or_equal_to => -180,:less_than_or_equal_to => 180}
                      
 validates :text, :presence => true,
                  :length       => { :within => 1..140 }
                  
 # **Note this is giving us problems on Heroku.  Squeaks with a duration of 23.7 hours or greater
 #   are sometimes being rejected. We'll just rely on duration for now. 
 # we'll allow for some slop in this
# validates :expires, :presence => true,
#                    :date => { :after => DateTime.now.utc, :before => DateTime.now.utc + 1.05 }
 
  validates :duration, :presence => true,
                      :numericality => {:greater_than => 0.0,:less_than_or_equal_to => 24}

  # before_save :decode_image

 ### NOTE: we don't need to do all the gmaps4rails_address junk b/c we already have the lat/long!
 ### Sooooo.... we put :process_geocoding => false to skip that!
 ### here we simply specify the lat/long columns in our database, and put in dummy addresses.
 acts_as_gmappable :lat => 'latitude', :lng => 'longitude', :checker => :prevent_geocoding, 
                  :address => "address", :normalized_address => "address",
                  :process_geocoding => false

  def prevent_geocoding
    address.blank? || (!lat.blank? && !lng.blank?) 
  end
  
  # TODO: consider making it possible to make a squeak by address
  #def gmaps4rails_address
    #describe how to retrieve the address from your model, if you use directly a db column, you can dry your code, see wiki
    #self.text
   # "Pye Lane, Shaw Mills, England"
  #end
  def gmaps4rails_infowindow
    #"<h4>#{name}</h4>" << "<h4>#{address}</h4>"

    # display: block;
    # font-size: 85%;
    #color: #666;

    caption = Time.now < self.expires ? "Expires in #{time_ago_in_words(self.expires)}" : "Expired #{time_ago_in_words(self.expires)} ago."
    "<font size=4 face='arial,sans-serif'>#{self.text} </font> <br/> <font color='#666' size=2 face='arial,sans-serif'> #{caption} </font>"
  end

  def gmaps4rails_marker_picture
    {
      "picture" => "/images/#{self.created_at < 5.minutes.ago ? 'old' : 'new'}_squeak_marker.png",  # self.image_path, # image_path column has to contain something like '/assets/my_pic.jpg'.
      "width" => 32, #beware to resize your pictures properly
      "height" => 32 #beware to resize your pictures properly
    }
  end


  def as_json(options={})
    result = super(:only => [:id, :latitude, :longitude, :duration, :expires,:created_at,:text,:timezone])     
    result["squeak"]["expires"] = self.expires.strftime("%Y-%m-%dT%H:%M:%SZ")
    result["squeak"]["created_at"] = self.created_at.strftime("%Y-%m-%dT%H:%M:%SZ")
    result["squeak"]["has_image"] = self.image.nil? ? "false" : "true"
    result
  end

  def image
    if self[:image].nil?
      puts "IMAGE is nil"
      return nil
    else      
      # Ugh! total hack! ActiveRecord and postgres 9.1 don't mix well? It is returning the data in bytea hex format

      im = self[:image]
      snippet = im[0..100]
      if snippet =~ /^x[0-9a-fA-F]+$/
        im = [self[:image][1..-1]].pack('H*')
      end

      return im
    end
  end

  #   result["user"]["name"] = name.capitalize
  
  #:private
  #def decode_image
  #  unless self.image.nil?
  #    if self.image.respond_to? :read
  #      self.image = self.image.read
  #    else
  #      self.image = Base64.decode64(self.image)
  #    end

      # TODO: perhaps this is better?
      #case 
      #when String
      #  self.image = Base64.decode64(self.image)
      #when ActionDispatch::Http::UploadedFile
      #  self.image = Base64.decode64(self.image)
      #end
   # end
  # end
end

