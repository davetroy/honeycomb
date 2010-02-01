require 'test_helper'

class MembershipTest < ActiveSupport::TestCase

  test "Membership can be created properly" do
    dave = people(:dave)
    dave.memberships.create(:plan => plans(:worker), :start_date => '2/1/2009')
    assert_equal 1, dave.memberships.size
  end
  
  test "Membership anniversary date is calculated correctly" do
    dave = people(:dave)
    dave.memberships.create(:plan => plans(:worker), :start_date => '2/5/2009')
    assert_equal 5, dave.memberships.first.anniversary_day
  end
  
end
