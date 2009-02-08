require 'digest/md5'
class Person < ActiveRecord::Base
  has_many :devices
  has_many :appearances, :through => :devices
  
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

  def self.by_day(day_number=Time.day_number)
    #Person.find_by_sql(['select distinct p.id,p.email,p.first_name,p.last_name,min(first_seen_at) first_seen_at,max(last_seen_at) last_seen_at,count(d.id) device_count FROM appearances a, people p, devices d where a.device_id=d.id and d.person_id=p.id and day_number=? group by email', day_number])    
    Person.find(:all, :select => 'id, email, min(first_seen_at) first_seen_at, max(last_seen_at) last_seen_at, count(devices.id) device_count', :group => 'people.id', :include => [:appearances, :devices])
  end
  
end
