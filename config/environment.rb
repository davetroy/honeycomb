# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem "json"
  config.gem "oauth", :version => "0.3.6"
  config.gem "activemerchant", :version => "1.4.2", :lib => 'active_merchant'
  config.gem "money", :version => "3.0.5"
  #config.gem "curb"
  
  config.time_zone = 'Eastern'
  #ENV['TZ'] = 'GMT'

  config.action_controller.session = {
    :session_key => '_honeycomb_session',
    :secret      => '47f103f92dc56c50c5c52e69c3f4de7dcab201893745ee0ecac68a720d518298f0b9429ea8213b13d15979304bba6b223b9ad949182f9cfb28d14cf606938734'
  }
end

ActionController::Base.asset_host = "http://#{DEFAULT_HOST}:#{DEFAULT_PORT}"

# We begin time at midnight EDT on 2/1/2009
STARTING_DAY = (Time.parse('2009-2-1 05:00:00 UTC').to_i / 86400)
DAY_PRICE=25

require 'digest/md5'
require 'json'
