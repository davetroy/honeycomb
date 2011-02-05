require 'test_helper'

class TimeExtensionTest < Test::Unit::TestCase

  def test_24_hour_difference
    today = Time.now
    tomorrow = today + 1.day
    assert_equal today.day_number, tomorrow.day_number - 1
  end
  
  def test_before_and_after_midnight
    today = Time.parse('2010-12-31 23:59')
    tomorrow = Time.parse('2011-1-1 00:01')
    assert_equal today.day_number, tomorrow.day_number - 1
  end

  def test_afternoon_times
    today = Time.parse('2011-02-1 12:01')
    12.times do |x|
      assert_equal today.day_number, (today + x.hours).day_number
    end
  end

end
