class Time
  def self.day_number
    (now.to_i / 86400) - STARTING_DAY
  end
end
