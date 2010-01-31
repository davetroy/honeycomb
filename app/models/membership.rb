class Membership < ActiveRecord::Base
  validates_presence_of :start_date
  belongs_to :person
  belongs_to :plan

  before_save :set_defaults
  
  named_scope :active, lambda { { :conditions => ['start_date <= ? AND ((end_date IS NULL) OR (end_date > ?))', Time.now, Time.now] } }
  named_scope :unbilled, lambda { { :conditions => ['(billed_through < ?) OR (billed_through IS NULL)', Time.now] } }

  def end_date
    self[:end_date] || Date.today
  end
  
  def date_range
    start_date..end_date
  end

  def months
    1 + (end_date.month - start_date.month) + 12 * (end_date.year - start_date.year)
  end

  def month_list
    nextdate = start_date
    list = []
    while nextdate<=end_date do
      list << nextdate
      nextdate += 1.month
    end
    list
  end

  def included_days_per_month
    plan.days_per_month || (plan.days_per_week * 4.5).to_i
  end

  def extra_days_in_month(m)
    days = person.daily_appearances(m.month,m.year).size - included_days_per_month
    days > 0 ? days : 0
  end

  def extra_days
    month_list.inject(0) { |days, m| extra_days_in_month(m) }
  end
  
  def monthly_charges
    months * plan.price
  end
    
  def day_charges
    extra_days * plan.price_per_day
  end

  def deposit
    end_date ? 0 : plan.deposit
  end
  
  def update_amount_due
    self.update_attributes(:amount_due => deposit + monthly_charges + day_charges, :billed_through => end_date)
  end
      
  def amount_due
    update_amount_due unless billed_through == end_date
    self[:amount_due]
  end

  private
  def set_defaults
    self.start_date ||= Date.today
  end

end
