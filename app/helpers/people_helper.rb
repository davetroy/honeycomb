module PeopleHelper

  def iterate_appearances_by_month(person)
    groups = person.daily_appearances_by_month
    
    by_month = groups.keys.sort.reverse_each do |date|
      month = date.month
      year = date.year
      concat("<div id='inner_panel'>")
      concat("<h3 style='color:black'>#{date.strftime('%B %Y')}</h3>")
      appearances = groups[date] 
      concat("<p>#{appearances.group_by { |a| a.day_number }.keys.size } appearances</p>")
      concat("<ul>")
      
      person.daily_appearances_by_week(month,year).each do |week,appearances|
        weekly_appearances = appearances.size
        concat("<li>Week #{week}: #{weekly_appearances}</li>")
      end
    
      concat("</ul>")
      
      plan = person.active_plan(month,year)
      #amount = person.compute_bill(month,year)
      #concat("<p>At the beginning of this month, you were on the #{plan.name} plan. You owe #{number_to_currency(amount)} for this month.</p>")
    
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
