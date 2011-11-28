=begin rdoc

= mapsqueak - a reference implementation for MapSqueak clients

=end

require 'json'
require 'koala'
require 'rexml/document'
include REXML

# MapSqueakSession - an class that encapsulates a session with the mapsqueak server. 
# 
class MapSqueakSession
  attr_accessor :host, :facebook_token
  attr_reader :session_cookie

  def initialize(host = 'http://mapsqueak.heroku.com', username=nil,password=nil)
    @host = host
  end

  # not implemented yet
  def sign_in(username,password)

  end

  # not implemented yet
  def sign_out

  end

  # post a new squeak. the squeak can either be whatever the ClientSqueak constructor accepts - 
  # a String of json or xml, or a hash, or a ClientSqueak object. Talk about flexibility!
  # the send_format must be :xml or :json
  def post_squeak(squeak,send_format = :xml)
    s = nil
    case squeak
      when ClientSqueak
      s = squeak
      when Hash
      s = ClientSqueak.new(squeak)
    end
    unless [:json, :xml].include?(send_format)
      $stderr.puts "Error: send_format must be in json or xml"
    end
    format_str = send_format.to_s
    data = s.send("to_#{format_str}")
			 
    `curl -v --data \'#{data}\' #{self.host}/squeaks.#{format_str} -H \"Content-Type: application/#{format_str}\"`
  end

  # get a list of no more than max squeaks closest to the given center_latitude/centerlongitude
  # The format must either be :json or :xml.
  # TODO: create a list of ClientSqueak objects, or make a get_squeak_objects function
  def get_squeaks(center_latitude,center_longitude,max = 100,format=:json)
    # curl "http://192.168.0.2:3000/squeaks.xml?num_squeaks=3&center_latitude=50.0&center_longitude=-1.8" 
    unless [:json, :xml].include?(format)
      $stderr.puts "Error: must be in json or xml"
    end
    
    squeaks = `curl #{self.host}/squeaks.#{format.to_s}?num_squeaks=#{max}&center_latitude=#{center_latitude}&center_longitude=#{center_longitude}`

    # TODO: parse these appropriately
  end

  # not implemented yet
  def get_my_squeaks(center_lat,center_long,max = 100,format=:json)
    unless [:json, :xml].include?(format)
      $stderr.puts "Error: must be in json or xml"
    end
    # TODO: add a hash based on the parameters requested and use session token
    `curl #{self.host}/squeaks.#{format.to_s}?num_squeaks=#{max}&center_latitude=#{center_latitude}&center_longitude=#{center_longitude}`
  end
end

# ClientSqueak - a class that encapsulates a client side squeak
# Note that if I am not the owner of a squeak, I will not know the user
class ClientSqueak
  attr_accessor :latitude, :longitude, :text, :duration, :expires, :username

  @@mandatory_parameters = %w[latitude longitude text duration]
  @@min_latitude = -90.0
  @@max_latitude = 90.0
  @@min_longitude = -180.0
  @@max_longitude = 180.0
  @@min_duration = 0.0 
  @@max_duration = 24.0
  @@max_text_length = 140

  # Initialize a new squeak which must be in an allowable format: 
  # json - a String representation of a JSON object
  #         e.g. {\"squeak\":{\"latitude\":\"54.1\",\"longitude\":\"-1.7\",\"duration\":\"2\",\"text\":\"Another squeak!\"}}
  # xml - a String representation of an XML blob
  #        e.g. <squeak><latitude>54.1</latitude><longitude>-1.7</longitude><text>Another squeak!</text><duration>2</duration></squeak>
  # hash - a hash representation of a squeak
  #         e.g. {:squeak => {:latitude=> 54.1, :longitude=>-1.69, :text => "Another squeak!", :duration => 2}}
  #         OR if you are lazy (like me) you can just specify the inner hash:
  #         e.g. {:latitude=> 54.1, :longitude=>-1.69, :text => "Another squeak!", :duration => 2}
  def initialize(squeak)
    @original_squeak = squeak
    temp_hash = {:squeak => {}}
    case squeak
    when Hash
      # just to be nice, we won't force the user to specify the outer wrapping
      if squeak.has_key? 'squeak'
	temp_hash = squeak.dup
      else
	temp_hash = {:squeak => squeak}
      end
      
    when String 
      begin
	temp_hash = JSON.parse(squeak)
      rescue Exception => e
	begin
	  doc = Document.new(squeak)
	  # a nice flexible way to parse the XML. as long as the XML 
	  # is only one level deep
	  doc.elements.each('squeak/') do | el |
	    el.each do |child|
	      temp_hash[:squeak][child.name.to_sym] = child.text
	    end
	  end
	rescue Exception => e2
	  raise "Can't parse squeak text: #{squeak}"
	end
      end
    end
    
    t = temp_hash['squeak'] || temp_hash[:squeak]
    parms_set = []
    t.keys.each do | k |
      # this will set and validate the parameters
      self.send("#{k.to_s}=",t[k])
      parms_set << k.to_s
    end

    # but we need to make sure that all of the mandatory parameters are defined
    unless (@@mandatory_parameters - parms_set).empty?
      raise "Must have duration, lat and long and text"
    end
  end

  # convert the squeak to XML format
  # e.g. <squeak><latitude>54.1</latitude><longitude>-1.7</longitude><text>Another squeak!</text><duration>2</duration></squeak>
  def to_xml
    params_xml = Document.new
    params_xml.add_element('squeak')
    params_xml.root << xml_element('latitude',self.latitude.to_s)
    params_xml.root << xml_element('longitude',self.longitude.to_s)
    params_xml.root << xml_element('text',self.text)
    params_xml.root << xml_element('duration',self.duration.to_s)
    params_xml
  end

  # convert the squeak to JSON format
  #  e.g. {\"squeak\":{\"latitude\":\"54.1\",\"longitude\":\"-1.7\",\"duration\":\"2\",\"text\":\"Another squeak!\"}}
  def to_json
    self.to_hash.to_json
  end
  
  # convert the squeak to a Hash
  def to_hash
    {
      :squeak=> {
	:latitude => self.latitude.to_s,
	:longitude => self.longitude.to_s,
	:duration => self.duration.to_s,
	:text => self.text
      }
    }
  end

  # set the latitude for the squeak
  # must be between  @@min_latitude and @@max_latitude 
  def latitude=(latitude)
    lat = latitude.to_f
    raise "Bad latitude" if lat < @@min_latitude
    raise "Bad latitude" if lat > @@max_latitude
    @latitude = lat
  end

  # set the longitude for the squeak
  # must be between @@min_longitude and @@max_longitude
  def longitude=(longitude)
    long = longitude.to_f
    raise "Bad longitude" if long < @@min_longitude
    raise "Bad longitude" if long > @@max_longitude
    @longitude = long
  end

  # set the time to live for the squeak
  # must be between @@min_duration and @@max_duration
  def duration=(duration)
    dur = duration.to_f
    raise "Bad duration" if dur < @@min_duration
    raise "Bad duration" if dur > @@max_duration
    @duration = dur
  end

  # set the message portion of the squeak
  # length can't exceed @@max_text_length
  def text=(txt)
    raise "Bad text length" unless txt.length <= @@max_text_length
    @text = txt.dup
  end

  # simply use to_s on the Hash representation
  def to_s
    self.to_hash.to_s
  end

  :private

  def xml_element(tag,text=nil)
    e = Element.new(tag)
    e << Text.new(text) unless text.nil?
    e
  end
end

