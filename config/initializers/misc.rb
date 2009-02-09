class Time
  STARTING_DAY = (Time.parse('2009-2-1').to_i / 86400)
  def self.day_number
    (now.to_i / 86400) - STARTING_DAY
  end
end
