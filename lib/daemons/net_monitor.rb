#!/usr/bin/env ruby
ENV["RAILS_ENV"] ||= defined?(Daemons) ? 'production' : 'development'

require File.dirname(__FILE__) + "/../../config/environment"

$running = true; Signal.trap("TERM") { $running = false }

while ($running) do
  Appearance.discover
  Appearance.refresh
  sleep 60
end