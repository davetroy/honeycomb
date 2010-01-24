class Person < ActiveRecord::Base
  has_many :devices
  has_many :appearances, :through => :devices, :order => "first_seen_at ASC"
  has_many :aliases

  has_many :people_prizes
  has_many :prizes, :through => :people_prizes

  attr :password
  attr :password_confirmation

  %w(foursquare twitter facebook).each { |site| has_one "#{site}_user".to_sym }

  after_create :create_facebook_user

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
  validates_presence_of :email
  # TODO: below needs fixed
  # validates_presence_of :first_name
  # validates_presence_of :last_name
  

  def balance_due
    owed_payments - payments.total
  end
  
  def gravatar_url(size=91)
    gravatar_hash = Digest::MD5.hexdigest(email)
    "http://www.gravatar.com/avatar/#{gravatar_hash}.jpg?s=#{size}"
  end
  
  alias_method :image, :gravatar_url

  # sent to a user to enable them to setup their account; key good for one day
  def temporary_key
    Digest::MD5.hexdigest("#{Time.now.day_number}#{id}#{self.email}")
  end

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
    self.foursquare_user.check_in if self.foursquare_user
    #self.twitter_user.check_in if self.twitter_user
  end
  
  def days
    appearances.group_by { |a| a.day_number }
  end

  # flattens multiple device appearances in a given day to count as just one daily apperance
  def daily_appearance_dates(month = nil,year = nil)
    daily_appearances(month,year).collect(&:first_seen_at)
  end

  def daily_appearances(month = nil,year = nil)
    cond = ["MONTH(first_seen_at) = ? AND YEAR(first_seen_at) = ?",month,year] if month && year
    apps = appearances.find(:all,:conditions => cond,:group => "day_number")
  end

  def daily_appearances_by_month
    daily_appearances.group_by { |a| Date.new(a.first_seen_at.year,a.first_seen_at.month) }
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
    active_plan(month,year).compute_bill(daily_appearance_dates(month,year))  || 0
  end
    
  def first_seen_at
    appearances.first.first_seen_at unless appearances.empty?
  end
  
  # array of all email addresses we have on file
  def payment_aliases
    list = self.aliases.map { |a| a.email }
    list << self.email
  end
    
  def before_save
    # re-register with facebook if email address changed
    if !new_record? && email_changed?
      self.facebook_user.register_with_facebook
    end
  end

end