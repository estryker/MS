class ShareRequest < ActiveRecord::Base
  # note that these belongs_to method calls need to be on a separate line
  belongs_to :user
  belongs_to :squeak
  # TODO: add mapsqueak to the inclusion list (for re-squeaks)
  validates :presence => true, :inclusion => { :in => %w[facebook twitter] }
end
