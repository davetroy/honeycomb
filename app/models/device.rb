class Device < ActiveRecord::Base
  belongs_to :person
  has_many :appearances, :order => 'first_seen_at'
  has_one :manufacturer, :foreign_key => 'mac_identifier', :primary_key => :manufacturer_id
  #has_one :current_appearance, :primary_key => 'appearance_id'

  def manufacturer_id
    mac[0..7]
  end

  def image
    person ? person.gravatar_url : '/images/unknown_user.jpg'
  end
  
  def assign(email)
    person = Person.find_or_create_by_email(email)
    self.update_attribute(:person_id, person.id)
    PersonMailer.deliver_confirmation(self)
  end
    
  def manufacturer_name
    manufacturer ? manufacturer.name : "Unknown Manufacturer"
  end
  
  def first_appearance
    appearances.first.first_seen_at
  end

  def last_appearance
    appearances.last.last_seen_at
  end
  
  def appearance_date_range
    "#{appearances.first.first_seen_at.to_s(:short_date)}-#{appearances.last.last_seen_at.to_s(:short_date)}"
  end
end
