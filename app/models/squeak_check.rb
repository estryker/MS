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
  validates_uniqueness_of [:squeak_id, :user_id]
end
