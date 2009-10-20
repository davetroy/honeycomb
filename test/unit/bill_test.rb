require 'test_helper'

class BillTest < ActiveSupport::TestCase

  test "Periodic bills are created properly" do
    dave = people(:dave)
    dave.memberships.create(:plan => plans(:worker), :start_date => '1/31/2009', :end_date => '5/15/2009')
    assert_equal ['1/31/2009', '2/28/2009', '3/31/2009', '4/30/2009'].map { |d| Time.parse(d) }, dave.bills.map(&:created_at)
    assert_equal 175*4, dave.bill_total
  end
  
  test "Basic membership per-incident bills are created properly" do
    dave = people(:dave)
    dave.memberships.create(:plan => plans(:basic), :start_date => '2/1/2009', :end_date => '6/15/2009')
    ['2/2/2009', '2/3/2009', '2/8/2009', '2/10/2009'].each { |d| Appearance.store(Time.parse(d), '192.168.1.129', '00:1b:63:c8:50:55') }
  end
  
end
