#!/usr/bin/env ruby
ENV["RAILS_ENV"] ||= defined?(Daemons) ? 'production' : 'development'

logfile = (ENV["RAILS_ENV"]=='production' ? '/var/log/messages' : File.dirname(__FILE__) + '/../db/data/dhcplog.txt')

require File.dirname(__FILE__) + "/../../config/environment"

Appearance.connection.execute("TRUNCATE TABLE appearances")

$running = true; Signal.trap("TERM") { $running = false }

while ($running) do
  File.readlines(logfile).each do |line|
    line.grep(/DHCPACK/).each do |l|
      Appearance.parse(l.chomp)
    end
  end
  sleep 60
end