#!/usr/bin/env ruby

# squeak.rb - update mapsqueak.heroku.com with a lat/long and a message (a squeak)

$LOAD_PATH.unshift File.dirname($PROGRAM_NAME)
$LOAD_PATH.unshift File.dirname($PROGRAM_NAME) + "/../lib"

require 'opt_simple'
require 'mapsqueak'

defaults = {
  :host => 'http://mapsqueak.heroku.com' # http://localhost:3000
}

opts = OptSimple.new(defaults).parse_opts! do 
  argument "--latitude", "Latitude in decimal degrees","LAT"
  argument "--longitude", "Longitude in decimal degrees","LONG"
  argument %w[-t --text], "Squeak text", "TEXT"
  argument %w[-d --duration], "Duration in hours","DURATION" do | arg |
    dur = arg.to_f
    if dur > 0.0 and dur <= 24.0 
      set_opt dur
    else
      error "Duration must be between 0 and 24 hours"
    end
  end
  option "--host", "MapSqueak host","URL"
  option %w[--access-token], "Facebook access token to post mapsqueak","TOKEN"
  flag %w[--facebook-test-user], "Create a Facebook test user using Mapsqueak's app token"
end
puts opts


# TODO: add signin capability
# TODO: re-add the facebook functionality
m = MapSqueakSession.new

m.post_squeak({
    :latitude => opts.latitude.dup.gsub("\\",''),
    :longitude =>opts.longitude.dup.gsub("\\",''),
    :text =>opts.text.dup,
    :duration => opts.duration
  })

__END__


puts "Auto confirming squeak ..."

update = {:squeak => Hash.new}
update[:squeak][:latitude] = initial_return_hash['squeak']['latitude']
update[:squeak][:longitude] = initial_return_hash['squeak']['longitude']

# PUT    /squeaks/:id(.:format)      {:action=>"update", :controller=>"squeaks"}
confirmation_curl_str = "curl -v --request PUT --data #{update.to_json} #{opts.host}/squeaks/#{initial_return_hash['squeak']['id']}.json -H \"Content-Type: application/json\" 2>> ruby_err.html"

puts confirmation_curl_str

confirmation_return = `#{confirmation_curl_str}`
puts "Confirmed."
confirmation_return_hash = JSON.parse(confirmation_return)
# Mapsqueak is all set, now update facebook if desired
user = nil
login_url = nil
if opts.include?('access-token')
  user = Koala::Facebook::API.new(opts.access_token)
elsif(opts.include?('facebook-test-user'))
  test_users = Koala::Facebook::TestUsers.new(:app_id => '107582139349630', :secret => "ca16bbd5834ab7d4b012ec5e84a0d003")
  user_info = test_users.create(true, "offline_access,read_stream,manage_pages,publish_stream")
  login_url = user_info['login_url']
  user = Koala::Facebook::API.new(user_info['access_token'])
end

unless user.nil?
  puts "Using the following facebook user: #{user.inspect}"

  picture_url = "http://maps.googleapis.com/maps/api/staticmap?center=#{update[:latitude]},#{update[:longitude]}&zoom=13&size=200x200&maptype=roadmap&markers=color:blue%7Clabel:M%7C#{update[:latitude]},#{update[:longitude]}&sensor=true"
 
  puts "Google image url: #{picture_url}"

  # Use google's static map api to get an image for the squeak
  id = user.put_wall_post("MapSqueak update at #{Time.now.strftime('')}",{:name => 'squeak name', 
			    :link => "#{opts.host}/squeaks/#{confirmation_return_hash['squeak']['id']}",
			    :caption => opts.text,
			    :description => "the description of the squeak, TBD",
			    :picture => picture_url})
  puts "Updated facebook  with id: #{id}"
  puts "Visit #{login_url} to see it ..." unless login_url.nil?
end


__END__

# To update the squeak using POST params, similar to the web client
#curl_str = "curl -v -F squeak[latitude]=#{opts.latitude} -F squeak[longitude]=#{opts.longitude} -F squeak[text]=\'#{opts.text}\' -F duration=#{opts.duration} #{opts.host}/squeaks/ 2> ruby_err.html"
# TODO: make this work. 
class MapSqueak
  include HTTParty
  format :json
  def self.squeak(host,params)
    post("#{host}/squeaks/",:body=>params)
  end
end
$stderr.puts params.to_json
MapSqueak.squeak(opts.host,params.to_json)
