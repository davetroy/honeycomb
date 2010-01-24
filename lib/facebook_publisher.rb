class FacebookPublisher < Facebooker::Rails::Publisher
  def self.new_run_template_id
    Facebooker::Rails::Publisher::FacebookTemplate.find_by_template_name('RunPublisher::new_run').bundle_id
  end

  def new_appearance_template
    one_line_story_template "{*actor*} just arrived at Beehive Baltimore ({*others*})."
  end

end
