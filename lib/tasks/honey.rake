namespace :honey do
  namespace :billing do
    desc "Generate invoices for the first time"
    task :initial => :environment do
      Person.find_each do |person|
        owed = person.owed_payments
        paid = person.payments.total
        due = owed - paid
        if due > 0
          puts "Generating an invoice for #{person.show_name} for $#{due}"
          person.invoices.create!(:amount => due)
          # possibly send out email here?
        else
          puts "#{person.show_name} does not owe any balance at this time (current balance $#{due})."
        end
      end
    end
  end
  
  namespace :load do
    desc "Seed the database with membership plans"
    task :plans => :environment do
      Plan.find_or_create_by_name("Basic", :deposit => 25, :price => 25, :days_per_month => 1, :price_per_day => 15)
      Plan.find_or_create_by_name("Worker Bee", :deposit => 175, :price => 175, :days_per_week => 3, :price_per_day => 15)
      Plan.find_or_create_by_name("Resident", :deposit => 275, :price => 275)
    end

    task :memberships => :environment do
      basic = Plan.find_by_name("Basic")
      worker = Plan.find_by_name("Worker Bee")
      resident = Plan.find_by_name("Resident")
      
      ["Dave Troy","Mike Brenner","Alan Grover","Greg Gershman","Michael Jovel"].each do |name|
        person = Person.find_by_first_name_and_last_name(*name.split)
        person.memberships.create!(:plan => worker,:start_date => Date.new(2009,2,1))
      end

      mike = Person.find_by_first_name_and_last_name("Mike","Subelsky")
      mike.memberships.create!(:plan => worker,:start_date => Date.new(2009,2,1),:end_date => Date.new(2009,12,31))
      mike.memberships.create!(:plan => basic,:start_date => Date.new(2010,1,1))
      
      jon = Person.find_by_first_name_and_last_name("Jonathan","Julian")
      jon.memberships.create!(:plan => basic,:start_date => Date.new(2009,2,1),:end_date => Date.new(2009,3,31))
      jon.memberships.create!(:plan => worker,:start_date => Date.new(2009,4,1))

      james = Person.find_by_first_name_and_last_name("James","Novak")
      james.memberships.create!(:plan => worker,:start_date => Date.new(2009,2,1),:end_date => Date.new(2009,7,31))
      james.memberships.create!(:plan => basic,:start_date => Date.new(2009,8,1))

      myke = Person.find_by_first_name_and_last_name("Mykel","Nahorniak")
      myke.memberships.create!(:plan => worker,:start_date => Date.new(2009,2,1),:end_date => Date.new(2009,7,31))
      myke.memberships.create!(:plan => basic,:start_date => Date.new(2009,8,1))

      paul = Person.find_by_first_name_and_last_name("Paul","Barry")
      paul.memberships.create!(:plan => worker,:start_date => Date.new(2009,2,1),:end_date => Date.new(2009,7,31))
      paul.memberships.create!(:plan => basic,:start_date => Date.new(2009,8,1))

      paul = Person.find_by_first_name_and_last_name("Paul","Barry")
      paul.memberships.create!(:plan => worker,:start_date => Date.new(2009,6,1),:end_date => Date.new(2009,7,31))
      paul.memberships.create!(:plan => basic,:start_date => Date.new(2009,8,1))

      Person.find_each do |person|
        person.memberships.create!(:plan => basic,:start_date => person.first_seen_at || Date.new(2009,2,1)) if person.memberships.empty?
      end
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