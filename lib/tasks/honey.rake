namespace :honey do
  namespace :billing do
    desc "Generate invoices for the first time"
    task :initial => :environment do
      sent = 0
      Person.find_each do |person|
        next if person.invoices.any?
        owed = person.owed_payments
        paid = person.payments.total
        due = owed - paid
        if due > 0
          puts "Generating an invoice for #{person.show_name} for $#{due}"
          #invoice = person.invoices.create!(:amount => due)
          #InvoiceMailer.deliver_initial_invoice(person,owed,paid,due)
          sent += 1
        else
          puts "#{person.show_name} does not owe any balance at this time (current balance $#{due})."
        end
        break if sent==5
      end
    end
  end
  
  namespace :load do
    desc "Seed the database with membership plans"
    task :plans => :environment do
      Plan.find_or_create_by_name("Basic", :deposit => 25, :price => 25, :days_per_month => 1, :price_per_day => 15)
      Plan.find_or_create_by_name("Worker Bee", :deposit => 175, :price => 175, :days_per_week => 3, :price_per_day => 15)
      Plan.find_or_create_by_name("Resident (4 Day)", :deposit => 225, :price => 225, :days_per_week => 4, :price_per_day => 15)
      Plan.find_or_create_by_name("Resident", :deposit => 275, :price => 275)
    end
    
    task :payments => :environment do
      IO.readlines("#{RAILS_ROOT}/db/payments_2009/2009payments.csv").each do |line|
        person_id,email,date,amount,type = line.split(/,/)
        details = { :email => email, :date => date, :type => type, :description => "Imported from #{type}" }
        Payment.create!(:created_at => date, :person_id => person_id,:amount => amount,:state => "Success",:details => details)
      end
    end
    
    desc "Load email aliases"
    task :aliases => :environment do
      IO.readlines("#{RAILS_ROOT}/db/aliases.txt").each do |line|
        aliases = line.strip.split
        person = nil
        aliases.find { |a| person=Person.find_by_email(a) }
        add_aliases = aliases - [person.email]
        add_aliases.each do |a|
          person.aliases.find_or_create_by_email(a)
          puts "#{person.id} = #{a}"
        end
      end
    end
  end
end