require 'digest/md5'
class Person < ActiveRecord::Base
  has_many :devices

  validates_uniqueness_of :email, :allow_null => true

  def gravatar_url
    gravatar_hash = Digest::MD5.hexdigest(email)
    "http://www.gravatar.com/avatar/#{gravatar_hash}.jpg?s=91"
  end
  
  def show_name
    namestring = "#{first_name} #{last_name}".strip
    namestring.blank? ? email : namestring
  end
  
  def is_setup?
    !"#{first_name} #{last_name}".strip.blank?
  end
  
end
