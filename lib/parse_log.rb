#!/usr/bin/env ruby

logfile = (ENV["RAILS_ENV"]=='production' ? '/var/log/messages' : File.dirname(__FILE__) + '/../db/data/dhcplog.txt')

require File.dirname(__FILE__) + "/../config/environment"

Appearance.connection.execute("TRUNCATE TABLE appearances")

File.readlines(logfile).each do |line|
  line.grep(/DHCPACK/).each do |l|
    Appearance.parse(l.chomp)
  end
end
