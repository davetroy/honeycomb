class Time
  def day_number
    ((self.to_i + self.gmtoff) / 86400) - STARTING_DAY
  end
end

{ :short_date  => "%x",              # 04/13/10
  :long_date   => "%a, %b %d, %Y"   # Tue, Apr 13, 2010 
}.each do |k, v|
  ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.update(k => v)
end
