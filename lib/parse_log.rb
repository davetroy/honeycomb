#!/usr/bin/env ruby

ENV["RAILS_ENV"] ||= defined?(Daemons) ? 'production' : 'development'

require File.dirname(__FILE__) + "/../config/environment"

Appearance.connection.execute("TRUNCATE TABLE appearances")

File.readlines(File.dirname(__FILE__) + '/../db/data/dhcplog.txt').each do |line|
  Appearance.parse(line.chomp)
end