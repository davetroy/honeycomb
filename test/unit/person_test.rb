require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  test "Confirm device info" do
    assert people(:dave).devices.map(&:name).include?("teflon")
    assert people(:greg).devices.map(&:name).include?("GERSHMANLAPTOP")
    assert people(:hive).devices.map(&:name).include?("budgetone")
  end

  test "Check for valid gravatar" do
    assert_equal "http://www.gravatar.com/avatar/6d4009aa8f8bc36460151e118dab51da.jpg?s=91", people(:dave).gravatar_url
    assert_equal "http://www.gravatar.com/avatar/df4e55573bf5caeaf5f0bb075294aa3b.jpg?s=91", people(:mikeb).gravatar_url
  end
  
  test "Ensure anniversary day is not a week ago" do
    dave = people(:dave)
    dave.memberships.create(:plan => plans(:worker), :start_date => Date.today - 1.week)
    assert_equal false, dave.is_anniversary_day?
  end

  test "Ensure anniversary day is computed correctly for last month" do
    dave = people(:dave)
    dave.memberships.create(:plan => plans(:worker), :start_date => Date.parse("12/#{Date.today.day}/2008"))
    assert_equal true, dave.is_anniversary_day?
  end
  
end
