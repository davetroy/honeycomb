class Person < ActiveRecord::Base
  has_many :devices
  has_many :appearances, :through => :devices

  has_many :people_prizes
  has_many :prizes, :through => :people_prizes

  has_many :memberships
  has_many :invoices, :through => :memberships

  has_many :payments
  
  has_one :foursquare_user
  has_one :twitter_user
  
  validates_uniqueness_of :email, :allow_null => true
    
  def gravatar_url(size=91)
    gravatar_hash = Digest::MD5.hexdigest(email)
    "http://www.gravatar.com/avatar/#{gravatar_hash}.jpg?s=#{size}"
  end
  
  alias_method :image, :gravatar_url

  # sent to a user to enable them to setup their account; key good for one day
  def temporary_key
    Digest::MD5.hexdigest("#{Time.now.day_number}#{id}#{person.email}")
  end

  def show_name
    namestring = "#{first_name} #{last_name}".strip
    namestring.blank? ? email : namestring
  end
  
  def is_setup?
    !"#{first_name} #{last_name}".strip.blank?
  end
  
  # Collapse from another person into us; good for duplicate records only
  def merge_from(person_id)
    from_person = Person.find(person_id)
    from_person.devices.each { |d| d.update_attribute(:person_id, self.id) }
    from_person.payments.each { |d| d.update_attribute(:person_id, self.id) }
    from_person.destroy
  end
  
  def check_in
    FoursquareOauth.check_in(self.foursquare_user) if self.foursquare_user
    #TwitterOauth.check_in(self) if self.twitter_user
  end
  
  def days
    appearances.group_by { |a| a.day_number }
  end

  def grouped_appearances
    appearances.group_by { |a| Date.civil(a.first_seen_at.year,a.first_seen_at.month) }
  end
end
