class AddFacebookTemplates < ActiveRecord::Migration
  def self.up
    create_table "facebook_templates", :force => true do |t|
      t.string "template_name", :null => false
      t.string "content_hash",  :null => false
      t.string "bundle_id"
    end

    add_index "facebook_templates", ["template_name"], :name => "index_facebook_templates_on_template_name", :unique => true
  end

  def self.down
    drop_table "facebook_templates"
  end
end
