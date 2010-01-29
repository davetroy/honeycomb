class FacebookUser < ActiveRecord::Base
  belongs_to :person
  before_create :register_with_facebook
  
  def register_with_facebook
    self.email_hash = "#{Zlib.crc32(self.person.email)}_#{Digest::MD5.hexdigest(self.person.email)}"
    Facebooker::Session.create.post('facebook.connect.registerUsers', :accounts => [{:email_hash => self.email_hash, :account_id => self.id}].to_json)
  end

  def publish_feed_story(params)
    "facebook_publish_feed_story(#{RunPublisher.new_run_template_id}, #{params.to_json});"
  end
  
  def user
    session = Facebooker::Session.create(Facebooker.api_key, Facebooker.secret_key)
    Facebooker::User.new(self.fb_uid, session)
  end
end
