class Appearance < ActiveRecord::Base
  has_many :people, :through => :devices
  belongs_to :device
  
  validates_presence_of :device_id
  
  attr_accessor :saw_at
  
  before_save :set_timefields
  after_save { |record| record.device.update_attribute(:appearance_id, record.id) }
  
  named_scope :current, :conditions => 'last_seen_at > NOW() - INTERVAL 5 MINUTE'
  named_scope :today, :conditions => ['last_seen_at >= ?', Time.today]

  def self.parse(line)
    # Feb  6 15:17:58 honey dhcpd: DHCPACK on 192.168.1.109 to 00:16:cb:be:b0:ac (Michael-Brenner-MBP) via eth0
    appeared_at, ip, mac, name = line.match(/^(.*?) honey dhcpd: DHCPACK on ([\d\.]+) to ([\w\:]+)\s?\(?(.*?)\)? via/).captures
    saw = Time.parse(appeared_at)
    saw_on_day_number = (saw.to_i / 86400) - STARTING_DAY
    
    device = Device.find_or_create_by_mac(mac)
    device.update_attribute(:name, name) unless name.blank?
    if appearance = find_by_device_id_and_day_number(device.id, saw_on_day_number)
      appearance.update_attributes(:saw_at => saw, :ip_address => ip)
    else
      appearance = device.appearances.create(:saw_at => saw, :ip_address => ip)
    end
    appearance
  end
  
  def self.refresh
    today.each do |a|
      ping_result = %x[#{PING_COMMAND} #{a.ip_address}]
      a.update_attribute(:saw_at => Time.now) if ping_result[/\s0% packet loss/]
    end
  end

  def image
    device.image
  end
  
  def show_name
    device.person ? device.person.show_name : 'Unidentified User'
  end
    
  def set_timefields
    self.day_number = (saw_at.to_i / 86400) - STARTING_DAY
    self.first_seen_at = saw_at if first_seen_at.nil? || saw_at < first_seen_at
    self.last_seen_at = saw_at if last_seen_at.nil? || saw_at > last_seen_at
  end
end
