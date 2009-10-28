require 'digest/md5'
class Person < ActiveRecord::Base
  has_many :devices
  has_many :appearances, :through => :devices

  has_many :people_prizes
  has_many :prizes, :through => :people_prizes

  has_many :memberships
  has_many :invoices, :through => :memberships
  
  validates_uniqueness_of :email, :allow_null => true
    
  def gravatar_url
    gravatar_hash = Digest::MD5.hexdigest(email)
    "http://www.gravatar.com/avatar/#{gravatar_hash}.jpg?s=91"
  end
  
  def show_name
    namestring = "#{first_name} #{last_name}".strip
    namestring.blank? ? email : namestring
  end
  
  # TODO: replace
  def bill_total
    invoices.inject(0) { |s, b| s += b.amount }
  end
  
  def is_setup?
    !"#{first_name} #{last_name}".strip.blank?
  end
  
  def self.by_day(day_number=Time.now.day_number)
    summary_sql = "select distinct p.id,min(first_seen_at) first_seen_at,max(last_seen_at) last_seen_at,count(DISTINCT d.id) device_count,a.day_number FROM appearances a, people p, devices d where a.device_id=d.id and d.person_id=p.id GROUP BY email,a.day_number HAVING a.day_number=#{day_number}"
    Person.connection.select_all(summary_sql).map { |s| s.merge(:person => Person.find(s.delete('id'))) }
    #Person.find(:all, :select => 'id, email, min(first_seen_at) first_seen_at, max(last_seen_at) last_seen_at, count(devices.id) device_count', :group => 'people.id', :include => [:appearances, :devices])
  end
  
  # Return true if *any* plan that this person is on has an anniversary today.
  def is_anniversary_day?
    memberships.active.select {|m| m.is_anniversary_day?}.size > 0
  end

end
