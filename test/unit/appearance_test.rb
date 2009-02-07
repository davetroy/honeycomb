require 'test_helper'

class AppearanceTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "DHCP log parsing for an existing device is correct" do
    appearance = Appearance.parse("Feb  6 15:17:58 honey dhcpd: DHCPACK on 192.168.1.109 to 00:16:cb:be:b0:ac (Michael-Brenner-MBP) via eth0")
    assert_equal Time.parse("Feb  6 15:17:58"), appearance.first_seen_at
    assert_equal "00:16:cb:be:b0:ac", appearance.device.mac
    assert_equal "Michael-Brenner-MBP", appearance.device.name
  end

  test "DHCP log parsing for a new device is correct" do
    appearance = Appearance.parse("Feb  6 15:20:01 honey dhcpd: DHCPACK on 192.168.1.110 to 00:19:d2:6d:0c:d6 (CILANTRO) via eth0")
    assert_equal Time.parse("Feb  6 15:20:01"), appearance.first_seen_at
    assert_equal "00:19:d2:6d:0c:d6", appearance.device.mac
    assert_equal "CILANTRO", appearance.device.name
    assert_nil appearance.device.person
  end

end
