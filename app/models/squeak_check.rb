# == Schema Information
#
# Table name: squeak_checks
#
#  id                     :integer         not null, primary key
#  squeak_id              :integer
#  user_id                :integer
#  checked_from_latitude  :float
#  checked_from_longitude :float
#  checked                :boolean
#  created_at             :datetime
#  updated_at             :datetime
#

class SqueakCheck < ActiveRecord::Base
  belongs_to :user
  belongs_to :squeak

  # This makes a unique compound key.  Beware of race conditions:
  # http://apidock.com/rails/v3.0.5/ActiveRecord/Validations/ClassMethods/validates_uniqueness_of under "Concurrency and Integrity"
  validates_uniqueness_of :squeak_id, :scope => :user_id  
end
