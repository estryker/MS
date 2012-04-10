class ShareRequest < ActiveRecord::Base
  belongs_to :user, :squeak
  # TODO: add mapsqueak to the inclusion list (for re-squeaks)
  validates :presence => true, :inclusion => { :in => %w[facebook twitter] }
end
