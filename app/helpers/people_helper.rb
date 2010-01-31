module PeopleHelper
  
  def display_date_range(r)
    "#{r.first.to_s(:short_date)} &ndash; #{r.last.to_s(:short_date)}"
  end

  def iterate_appearances_by_month(person)
    groups = person.daily_appearances_by_month
    
    by_month = groups.keys.sort.reverse_each do |date|
      month = date.month
      year = date.year
      concat("<div id='inner_panel'>")
      appearances = groups[date] 
      day_count = appearances.group_by { |a| a.day_number }.keys.size
      concat("<h3 style='color:black'>#{date.strftime('%B %Y')}: #{day_count} Days</h3>")
      concat("<ul>")
      
      person.daily_appearances_by_week(month,year).each do |week,appearances|
        weekly_appearances = appearances.size
        concat("<li>Week #{week}: #{weekly_appearances}</li>")
      end
    
      concat("</ul>")
          
      concat("</div>")
    end
    nil
  end

  def pay_invoice_cue(person)
    if person.balance_due > 0 && person.invoices.any?
      amount = person.invoices.last.amount
      text = <<-TEXT
      Your most recent invoice was for #{number_to_currency(amount)}. 
      #{link_to("Pay this invoice",new_payment_path(:amount => amount,:person_id => person.id))}
      TEXT
    else
      "You do not owe a balance at this time."
    end
  end
end
