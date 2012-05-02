# == Schema Information
#
# Table name: share_requests
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  squeak_id  :integer
#  provider   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class ShareRequest < ActiveRecord::Base
  # note that these belongs_to method calls need to be on a separate line
  belongs_to :user
  belongs_to :squeak
  # TODO: add mapsqueak to the inclusion list (for re-squeaks)
  validates :provider, :presence => true, :inclusion => { :in => %w[facebook twitter] }
end
