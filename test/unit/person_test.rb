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
  
  test "Check to see that People.by_day works" do
    Appearance.create(:device_id => devices(:teflon).id, :saw_at => Time.now, :ip_address => '192.168.1.110')
    Appearance.create(:device_id => devices(:teflon).id, :saw_at => 10.minutes.ago, :ip_address => '192.168.1.110')
    summary = Person.by_day
    assert_equal 1, summary.size
    assert_equal 1, summary.first['device_count'].to_i
  end
  
end
