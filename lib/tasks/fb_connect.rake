namespace :honey do
  namespace :fb_connect do
    desc 'Register users with Facebook'
    task :sync_users => :environment do
      
      accounts = Person.all.map do |person|
        fbuser = person.facebook_user || person.create_facebook_user
        {:email_hash => fbuser.email_hash, :account_id => person.id}
      end.to_json

      i = 0
      begin
        Facebooker::Session.create.post('facebook.connect.registerUsers', :accounts => accounts)
      rescue 
        i += 1
        retry if i < 3
      end
      
    end
    
    desc 'Publish Templates'
    task :publish => :environment do
      puts "Cleaning up any old templates ..."
      Facebooker::Rails::Publisher::FacebookTemplate.destroy_all
      puts "Done!"

      FacebookPublisher.register_all_templates
      puts "Finished registering all templates."
    end
  end
end