module PeopleHelper

  def iterate_appearances_by_month(person)
    person.appearance_range.reverse_each do |month,year|
      concat("<h3 style='color:black'>#{Time::RFC2822_MONTH_NAME[month-1]} #{year}</h3>")
      concat("<div style='background-color: white;color: black;padding:0.25em 0 0.25em 0.5em;width:50%;'>")
      monthly_appearances = person.daily_appearance_dates(month,year).size
      concat("<p>#{monthly_appearances} appearances</p>")

      concat("<ul>")
      
      person.daily_appearances_by_week(month,year).each do |week,appearances|
        weekly_appearances = appearances.size
        concat("<li>Week #{week}: #{weekly_appearances}</li>")
      end

      concat("</ul>")
      
      plan = person.active_plan(month,year)
      amount = person.compute_bill(month,year)
      concat("<p>At the beginning of this month, you were on the #{plan.name} plan. You owe #{number_to_currency(amount)} for this month.</p>")
    
      concat("</div>")
    end
    return
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
