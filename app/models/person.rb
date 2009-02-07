require 'digest/md5'
class Person < ActiveRecord::Base
  has_many :devices

  def gravatar_url
    gravatar_hash = Digest::MD5.hexdigest(email)
    "http://www.gravatar.com/avatar/#{gravatar_hash}.jpg"
  end
  
end
