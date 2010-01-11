namespace :honey do
  namespace :load do
    desc "Seed the database with membership plans"
    task :plans => :environment do
      Plan.find_or_create_by_name("Basic", :deposit => 25, :price => 25, :days_per_month => 1, :price_per_day => 15)
      Plan.find_or_create_by_name("Worker Bee", :deposit => 175, :price => 175, :days_per_week => 3, :price_per_day => 15)
      Plan.find_or_create_by_name("Resident", :deposit => 275, :price => 275)
    end

    task :payments => :environment do
      IO.readlines("#{RAILS_ROOT}/tmp/2009payments.csv").each do |line|
        person_id,email,date,amount,type = line.split(/,/)
        details = { :email => email, :date => date, :type => type, :description => "Loaded manually" }
        Payment.create!(:person_id => person_id,:amount => amount,:state => "Success",:details => details)
      end
    end
  end
end