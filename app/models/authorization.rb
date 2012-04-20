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
#

class Authorization < ActiveRecord::Base
  belongs_to :user
  validates :provider, :uid, :presence => true
  
  def self.find_or_create(auth_hash)
    unless auth = find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      # Note that info/email may be nil (e.g. Twitter)
      user = User.create(:name => auth_hash["info"]["name"])
      # only add the email if it is not nil, b/c of the regex checker
      user.email = auth_hash["info"]["email"] if auth_hash["info"].has_key("email")
      #TODO: check this! if it isn't a successful save, then do something smart
      user.save
      
      auth = create(:user => user, :provider => auth_hash["provider"], :uid => auth_hash["uid"])
    end

    auth
  end
end
