class Person < ActiveRecord::Base
  has_many :devices
  has_many :appearances, :through => :devices, :order => "first_seen_at ASC"
  has_many :aliases

  has_many :people_prizes
  has_many :prizes, :through => :people_prizes

  attr :password
  attr :password_confirmation

  %w(foursquare twitter facebook).each { |site| has_one "#{site}_user" }

  after_create :create_facebook_user

  named_scope :members, {:include => :memberships, :conditions => 'memberships.person_id IS NOT NULL'}
  named_scope :drop_ins, {:include => :memberships, :conditions => 'memberships.person_id IS NULL'}

  has_many :memberships, :order => "start_date ASC" do
    def total_due
      all.inject(0) { |accum, m| accum += m.amount_due }
    end
  end
  
  has_many :invoices do
    def total
      sum('amount').to_f / 100
    end
  end

  has_many :payments do
    def total
      sum('amount').to_f / 100
    end
    
    def issue_credit(amount, dt=Date.today)
      create(:amount => amount, :created_at=>dt, :state => 'Complete', :details => {:type => :credit})
    end
  end
  
  validates_uniqueness_of :email, :allow_null => true
  validates_presence_of :email
  # TODO: below needs fixed
  # validates_presence_of :first_name
  # validates_presence_of :last_name
  
  def gravatar_url(size=91)
    gravatar_hash = Digest::MD5.hexdigest(email)
    "http://www.gravatar.com/avatar/#{gravatar_hash}.jpg?s=#{size}"
  end
  
  alias_method :image, :gravatar_url

  # sent to a user to enable them to setup their account; key good for one day
  def temporary_key
    Digest::MD5.hexdigest("#{Time.now.day_number}#{id}#{self.email}")
  end

  def namestring
    "#{first_name} #{last_name}".strip
  end

  def is_setup?
    !namestring.blank?
  end
  
  def show_name
    is_setup? ? namestring : email
  end
    
  def total_owed
    total_due - payments.completed.total
  end

  def drop_in_total_due
    DAY_PRICE * drop_in_day_count
  end
  
  def total_due
    memberships.total_due + drop_in_total_due
  end
  
  # Collapse from another person into us; good for duplicate records only
  def merge_from(person_id)
    from_person = Person.find(person_id)
    from_person.devices.each { |d| d.update_attribute(:person_id, self.id) }
    from_person.payments.each { |d| d.update_attribute(:person_id, self.id) }
    from_person.destroy
  end
  
  # Number of days outside of membership
  def drop_in_day_count
    day_list = days.keys
    memberships.each { |m| day_list.delete_if { |d| m.day_range===d } }
    day_list.size
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
    appearances.find(:all,:conditions => cond,:group => "day_number")
  end

  def daily_appearances_by_month
    daily_appearances.group_by { |a| Date.new(a.first_seen_at.year,a.first_seen_at.month) }
  end
  
  # returns an ordered hash with keys = week number, values = appearance dates in that week
  def daily_appearances_by_week(month,year)
    daily_appearance_dates(month,year).group_by { |a| a.strftime("%W") }
  end
      
  def first_seen_at
    appearances.first.first_seen_at unless appearances.empty?
  end
  
  # array of all email addresses we have on file
  def payment_aliases
    list = self.aliases.map { |a| a.email }
    list << self.email
  end
  
  def check_in
    self.foursquare_user.check_in if self.foursquare_user
    #self.twitter_user.check_in if self.twitter_user
  end
    
  def before_save
    # re-register with facebook if email address changed
    if !new_record? && email_changed?
      self.facebook_user.register_with_facebook
    end
  end

end