class Appearance < ActiveRecord::Base
  has_many :people, :through => :devices
  belongs_to :device
  
  validates_presence_of :device_id
  
  attr_accessor :saw_at
  
  before_save :set_timefields
  after_save { |record| record.device.update_attribute(:appearance_id, record.id) }
  
  named_scope :current, :conditions => 'last_seen_at > NOW() - INTERVAL 5 MINUTE'
  named_scope :today, :conditions => ['day_number=?', Time.now.day_number]
  named_scope :recent, :order => 'id DESC'

  def self.store(saw, ip, mac, name=nil)
    device = Device.find_or_create_by_mac(mac)
    device.update_attribute(:name, name) unless name.blank?
    if appearance = find_by_device_id_and_day_number(device.id, saw.day_number)
      appearance.update_attributes(:saw_at => saw, :ip_address => ip)
    else
      appearance = device.appearances.create(:saw_at => saw, :ip_address => ip)
    end
    appearance
  end
  
  def self.parse(line)
    # Feb  6 15:17:58 honey dhcpd: DHCPACK on 192.168.1.109 to 00:16:cb:be:b0:ac (Michael-Brenner-MBP) via eth0
    appeared_at, ip, mac, name = line.match(/^(.*?) honey dhcpd: DHCPACK on ([\d\.]+) to ([\w\:]+)\s?\(?(.*?)\)? via/).captures
    store(Time.parse(appeared_at), ip, mac, name)
  end
  
  # Keep pinging people and see if they are still online
  def self.refresh
    today.each do |a|
      ping_result = %x[#{PING_COMMAND} #{a.ip_address}]
      a.update_attribute(:saw_at, Time.now) if ping_result[/\s0% packet loss/]
    end
  end
  
  # Discover any non-dhcp nodes on the network
  def self.discover
    # ? (192.168.1.1) at 00:1A:70:3F:2D:12 [ether] on eth0
    %x[#{NMAP_COMMAND} -sP 192.168.1.0/24]
    arplist = %x[#{ARP_COMMAND} -a].split(/\n/)
    arplist.each do |l|
      if matches = l.match(/^\? \(([\d\.]+)\) at ([\w:]+)/)
        ip, mac = matches.captures
        store(Time.now, ip, mac) if ip && mac
      end
    end
  end

  def image
    device.image
  end
  
  def show_name
    device.person ? device.person.show_name : 'Unidentified User'
  end
    
  def set_timefields
    self.day_number = saw_at.day_number
    self.first_seen_at = saw_at if first_seen_at.nil? || saw_at < first_seen_at
    self.last_seen_at = saw_at if last_seen_at.nil? || saw_at > last_seen_at
  end
end
