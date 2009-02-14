class Time
  def day_number
    ((self.to_i + self.gmtoff) / 86400) - STARTING_DAY
  end
end
