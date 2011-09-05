require 'test_helper'

class SqueekTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: squeeks
#
#  id         :integer         not null, primary key
#  latitude   :float
#  longitude  :float
#  time_utc   :datetime
#  text       :string(255)
#  expires    :datetime
#  created_at :datetime
#  updated_at :datetime
#  gmaps      :boolean
#  user_email :string(255)
#

