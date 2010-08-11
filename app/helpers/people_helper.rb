module PeopleHelper

  def iterate_appearances_by_month(person)
    groups = person.daily_appearances_by_month
    
    by_month = groups.keys.sort.reverse.each do |date|
      month = date.month
      year = date.year
      concat("<div id='inner_panel'>")
      appearances = groups[date] 
      day_count = appearances.group_by { |a| a.day_number }.keys.size
      concat("<h3 style='color:black'>#{date.strftime('%B %Y')}: #{day_count} Days</h3>")
      concat("<ul>")
      
      person.daily_appearances_by_week(month,year).reverse.each do |week,appearances|
        weekly_appearances = appearances.size
        concat("<li>Week #{week}: #{weekly_appearances}</li>")
      end
    
      concat("</ul>")
          
      concat("</div>")
    end
    nil
  end

end
