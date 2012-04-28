# == Schema Information
#
# Table name: authorizations
#
#  id         :integer         not null, primary key
#  provider   :string(255)
#  uid        :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  secret     :string(255)
#  token      :string(255)
#

# an authorization is something that belongs to a user. A user may have more than one authorization,
# for e.g. facebook _and_ twitter. Some of the components of that authorization may need to be
# reset at login
class Authorization < ActiveRecord::Base
  belongs_to :user
  validates :provider, :uid, :presence => true
  

  def update_credentials!(auth_hash)
     self.token = auth_hash["credentials"]["token"]
     self.secret = auth_hash["credentials"]["secret"]
     self.save
  end
  
  # override the class method for find_or_create to take an OmniAuth auth_hash
  def self.find_or_create(auth_hash)
    # note to self: this is ActiveRecord's dynamic attribute based finder (implemented using 'method_missing')
    unless auth = find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      # Note that info/email may be nil (e.g. Twitter)
      user = User.create :name => auth_hash["info"]["name"]

      puts user.inspect

      # only add the email if it is not nil, b/c of the regex checker
      user.email = auth_hash["info"]["email"] if auth_hash["info"].has_key?("email") and not auth_hash["info"]["email"].empty?

      puts user.inspect

      #TODO: check this! if it isn't a successful save, then do something smart
      if user.save
        puts "User saved!"
        puts user.inspect
        auth = create :user => user, :provider => auth_hash["provider"], :uid => auth_hash["uid"],:secret => auth_hash["credentials"]["secret"],:token => auth_hash["credentials"]["token"]
        puts user.inspect
        puts auth.inspect
      else
        puts "Couldn't create user"
        user.errors.each{|attr,msg| puts "#{attr} - #{msg}" }
      end
    end
    auth.update_credentials!(auth_hash)
    auth
  end
end
