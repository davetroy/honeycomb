require 'test_helper'

class MembershipTest < ActiveSupport::TestCase

  test "Membership can be created properly" do
    dave = people(:dave)
    dave.memberships.create(:plan => plans(:worker), :start_date => '2/1/2009')
    assert_equal 1, dave.memberships.size
  end
  
end
