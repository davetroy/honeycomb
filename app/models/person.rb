require 'digest/md5'
class Person < ActiveRecord::Base
  has_many :devices
  has_many :appearances, :through => :devices, :order => "first_seen_at ASC"

  has_many :people_prizes
  has_many :prizes, :through => :people_prizes

  has_many :memberships, :order => "start_date ASC" do
    # return the membership active at the beginning of the current month, or of the month specified 
    def active_in_month(month = nil,year = nil)
      today = Date.today
      month ||= today.month
      year ||= today.year
      date = Date.new(year,month,1)
      find(:first,:conditions => ["start_date <= ? AND (end_date IS NULL OR end_date >= ?)",date,date])
    end
  end
  
  has_many :invoices do
    def descending
      find(:all,:order => 'created_at DESC')
    end

    def total
      sum('amount').to_f / 100
    end
  end

  has_many :payments do
    def descending
      find(:all,:order => 'created_at DESC')
    end
    
    def total
      sum('amount').to_f / 100
    end
  end
  
  validates_uniqueness_of :email, :allow_null => true

  def balance_due
    owed_payments - payments.total
  end
  
  def gravatar_url(size=91)
    gravatar_hash = Digest::MD5.hexdigest(email)
    "http://www.gravatar.com/avatar/#{gravatar_hash}.jpg?s=#{size}"
  end
  
  alias_method :image, :gravatar_url
  
  def show_name
    namestring = "#{first_name} #{last_name}".strip
    namestring.blank? ? email : namestring
  end
  
  def active_plan(month = nil,year = nil)
    mem = memberships.active_in_month(month,year)
    mem ? mem.plan : nil
  end
  
  # calculate how much a user owes for all months prior to this one
  def owed_payments
    range = appearance_range
    today = Date.today
    range.delete([today.month,today.year])
    owed = 0 
    range.each do |month,year|
      next unless active_plan(month,year) # skip the Beehive Baltimore user who has gaps
      owed += compute_bill(month,year)
    end
    owed
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
  
  # Collapse from another person into us; good for duplicate records only
  def merge_from(person_id)
    from_person = Person.find(person_id)
    from_person.devices.each { |d| d.update_attribute(:person_id, self.id) }
    from_person.payments.each { |d| d.update_attribute(:person_id, self.id) }
    from_person.destroy
  end

  # flattens multiple device appearances in a given day to count as just one daily apperance
  def daily_appearance_dates(month,year)
    apps = appearances.find(:all,:conditions => ["MONTH(first_seen_at) = ? AND YEAR(first_seen_at) = ?",month,year],:group => "day_number")
    apps.collect(&:first_seen_at)
  end

  # returns an ordered hash with keys = week number, values = appearance dates in that week
  def daily_appearances_by_week(month,year)
    daily_appearance_dates(month,year).group_by { |a| a.strftime("%W") } # ruby doesn't have a "week number" function and I don't want to screw up writing my own
  end

  # returns an array of months for which the user has appearances, example: [[2009,10],[2009,11],[2010,1]]
  def appearance_range
    first = appearances.first && appearances.first.first_seen_at
    last = appearances.last && appearances.last.first_seen_at
    if first && last
      range = (Date.civil(first.year,first.month)..(Date.civil(last.year,last.month)))
      range.collect { |d| [d.month,d.year] }.uniq
    else
      []
    end
  end
  
  def compute_bill(month,year)
    # plan = active_plan(month,year)
    # plan ? active_plan(month,year).compute_bill(monthly_appearances,excess_weekly_appearances) : -1.0
    active_plan(month,year).compute_bill(daily_appearance_dates(month,year))  
  end
    
  def first_seen_at
    appearances.first.first_seen_at unless appearances.empty?
  end
end