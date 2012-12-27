# == Schema Information
#
# Table name: roles
#
#  id                  :integer         not null, primary key
#  name                :string(255)
#  max_squeak_duration :float
#  created_at          :datetime
#  updated_at          :datetime
#

class Role < ActiveRecord::Base
  has_many :users
end
