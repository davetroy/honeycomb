class TwitterUser < ActiveRecord::Base
  belongs_to :person
  
  include OauthMethods
  
  CONSUMER_TOKEN = "aVSiSKcPrLC27CDqe14cCg"
  CONSUMER_KEY = "UkRztJCb90YA4pHumzNoWMc4g4YEGR0mFqu9s6n6G8"

  API = OAuth::Consumer.new(CONSUMER_TOKEN, CONSUMER_KEY, {
         :site               => "http://api.twitter.com",
         :scheme             => :header,
         :http_method        => :post,
         :request_token_path => "/oauth/request_token",
         :access_token_path  => "/oauth/access_token",
         :authorize_path     => "/oauth/authorize"
        })
              
  def self.get_request_token
    API.get_request_token(:oauth_callback => "http://hive.beehivebaltimore.org/oauth/setup_twitter")
  end
    
  def update_access_token(token_info, oauth_verifier)
    request_token = OAuth::RequestToken.new(API, token_info[:token], token_info[:secret])
    atoken = request_token.get_access_token(:oauth_verifier => oauth_verifier)
    update_attributes(:token => atoken.token, :secret => atoken.secret)
    user = self.get_user
    update_attribute(:username, user['screen_name'])
  end
  
  def get_user
    get('http://twitter.com/account/verify_credentials.json')
  end
  
end