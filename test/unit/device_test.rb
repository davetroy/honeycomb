require 'test_helper'

class DeviceTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "Correct manufacturers are associated with each device" do
    assert_equal "Apple Computer Inc.", devices(:teflon).manufacturer.name
    assert_equal "Grandstream Networks, Inc.", devices(:budgetone).manufacturer.name
    assert_equal "Intel Corporate", devices(:dell_laptop).manufacturer.name    
  end
  
  test "Devices belong to the right people" do
    assert_equal people(:dave), devices(:teflon).person
    assert_equal people(:hive), devices(:budgetone).person
    assert_equal people(:greg), devices(:dell_laptop).person
  end
  
end
