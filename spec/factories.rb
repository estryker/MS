# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.name                  "Ethan Stryker"
  user.email                 "e.stryker@gmail.com"
  user.password              "foobar"
  user.password_confirmation "foobar"
end

Factory.define :squeek do |squeek|
  squeek.latitude   54.1
  squeek.longitude  -1.4
  squeek.text  'factory update'
  squeek.time_utc 0.hours.ago
  squeek.duration  2
  squeek.user_email 'e.stryker@gmail.com'
end
