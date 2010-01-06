namespace :honey do
  namespace :load do
    desc "Seed the database with membership plans"
    task :plans => :environment do
      Plan.find_or_create_by_name("Basic", :deposit => 25, :price => 25, :days_per_month => 1, :price_per_day => 15)
      Plan.find_or_create_by_name("Worker Bee", :deposit => 175, :price => 175, :days_per_week => 3, :price_per_day => 15)
      Plan.find_or_create_by_name("Resident", :deposit => 275, :price => 275)
    end
  end
end