# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.name                  "Ethan Stryker"
  #user.email                 "e.stryker@gmail.com"
  #user.password              "foobar"
  #user.password_confirmation "foobar"
end


Factory.define :squeak do |squeak|
  squeak.latitude   54.1
  squeak.longitude  -1.4
  squeak.text  'factory update'
  squeak.time_utc 0.hours.ago
  squeak.duration  2
  squeak.expires  2.hours.from_now
  # @images = ["xFFFF",["xFFFF"[1..-1]].pack("H*")]

  squeak.sequence(:image) {|n| ["xFFFF",["xFFFF"[1..-1]].pack("H*")][n%2] }
  #squeak.image  "xFFFF"
#end
end
