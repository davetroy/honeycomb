require 'test_helper'

class ManufacturerTest < ActiveSupport::TestCase
  test "Apple made the Mac laptops" do
    macs = Manufacturer.find(:all, :conditions => ['name LIKE ?', "Apple%"]).map(&:devices).flatten
    assert 2, macs.size
  end
end
