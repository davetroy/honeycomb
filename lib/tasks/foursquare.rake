namespace :honey do
  namespace :foursquare do
    desc 'Get updated info from Foursquare'
    task :sync => :environment do
      FoursquareUser.all.each { |u| u.sync }      
    end
  end
end