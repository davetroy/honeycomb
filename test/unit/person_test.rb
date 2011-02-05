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
  
  test "daily_appearances workday M-F 6a - 6p logic" do
    dave = people(:dave)
    dave.devices = [devices(:teflon)]
    assert dave.devices.size == 1
    macbook = dave.devices.first
    # show up for work
    now = Time.parse('2011-2-3 9:05')
    macbook.appearances.create(:saw_at => now, :ip_address => "10.0.0.123")
    assert dave.daily_appearances(now.month, now.year).size == 1
    # show up for work, early
    now = Time.parse('2011-2-4 6:05')
    macbook.appearances.create(:saw_at => now, :ip_address => "10.0.0.123")
    assert dave.daily_appearances(now.month, now.year).size == 2
    # show up after 6pm for a meetup
    now = Time.parse('2011-2-7 18:15')
    macbook.appearances.create(:saw_at => now, :ip_address => "10.0.0.123")
    assert dave.daily_appearances(now.month, now.year).size == 2
    # show up super-late for nightowls: 11pm
    now = Time.parse('2011-2-8 22:53')
    macbook.appearances.create(:saw_at => now, :ip_address => "10.0.0.123")
    assert dave.daily_appearances(now.month, now.year).size == 2
    # why are you here so early?
    now = Time.parse('2011-2-9 5:34')
    macbook.appearances.create(:saw_at => now, :ip_address => "10.0.0.123")
    assert dave.daily_appearances(now.month, now.year).size == 2
  end
  
end
