class Time
  STARTING_DAY = (Time.parse('2009-2-1 0:0:0 UTC').to_i / 86400)
  def day_number
    # TODO: this needs to be inferred from timezone info
    ((self.to_i + self.gmtoff) / 86400) - STARTING_DAY
  end
end
