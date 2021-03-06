class Membership < ActiveRecord::Base

  belongs_to :person
  belongs_to :plan

  before_save :set_defaults
  
  def end_date
    self[:end_date] || Date.today.to_time
  end
  
  def day_range
    start_date.to_time.day_number..end_date.to_time.day_number
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

  def extra_days_in_month(m)
    days = person.daily_appearances(m.month,m.year).size - plan.included_days_per_month
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
    self[:end_date] ? 0 : plan.deposit
  end
  
  def update_amount_due
    amount = deposit + monthly_charges + day_charges
    self.update_attributes(:amount_due => amount*100, :billed_through => end_date)
  end
  
  def amount_due
    update_amount_due unless billed_through == end_date
    self[:amount_due].to_f / 100
  end

  private
  def set_defaults
    self.start_date ||= Date.today
  end

end
