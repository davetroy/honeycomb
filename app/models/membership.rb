class Membership < ActiveRecord::Base
  belongs_to :person
  belongs_to :plan
  has_many :invoices

  before_save :set_defaults
  
  named_scope :active, lambda { { :conditions => ['start_date <= ? AND ((end_date IS NULL) OR (end_date > ?))', Time.now, Time.now] } }
  named_scope :unbilled, lambda { { :conditions => ['(billed_through < ?) OR (billed_through IS NULL)', Time.now] } }
  
  def set_defaults
    self.start_date ||= Time.now
  end

  def do_billing
    base_date = billed_through || start_date
    stop_date = end_date || Time.now
    monthcount = 0
    bill_date = base_date
    while (bill_date <= stop_date)
      invoices.create(:amount => plan.price, :created_at => bill_date)
      monthcount += 1
      bill_date = base_date + monthcount.month
    end
  end

  def invoice_appearance(a)
    p "billing appearance"
  end
  
  def anniversary_day
    self.start_date.day
  end

  def is_anniversary_day?
    anniversary_day == Date.today.day
  end

end
