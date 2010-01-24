class FoursquareUser < ActiveRecord::Base
  belongs_to :person
  
  include OauthMethods
  
  CONSUMER_TOKEN = "G13C2EUPJHCZWFXK2YP1DZGHY4NLZCE3J2KJNTCDL3S3R0WX"
  CONSUMER_KEY = "AGBVZRBSM3GUAEQ4UZZV3WHDO3QCOWCM4WN1S1DA03AIZIYF"
  VENUE_ID = 131287
  
  AUTH = OAuth::Consumer.new(CONSUMER_TOKEN, CONSUMER_KEY, {
         :site               => "http://foursquare.com",
         :scheme             => :header,
         :http_method        => :post,
         :request_token_path => "/oauth/request_token",
         :access_token_path  => "/oauth/access_token",
         :authorize_path     => "/oauth/authorize"
        })
        
  API = OAuth::Consumer.new(CONSUMER_TOKEN, CONSUMER_KEY, {
         :site               => "http://api.foursquare.com",
         :scheme             => :header,
         :http_method        => :post
        })
        
  def self.get_request_token
    AUTH.get_request_token
  end
  
  # Use request token info from session to get an access token, then store that info
  def update_access_token(token_info)
    request_token = OAuth::RequestToken.new(AUTH, token_info[:token], token_info[:secret])
    atoken = request_token.get_access_token
    update_attributes(:token => atoken.token, :secret => atoken.secret)
    user = self.get_user
    update_attributes(:firstname => user['firstname'], :lastname => user['lastname'], :photo => user['photo'])
  end
  
  # Wrappers for foursquare API method calls
  def check_in
    post("/v1/checkin?vid=#{VENUE_ID}&twitter=#{self.update_twitter}&facebook=#{self.update_facebook}")
    update_attribute(:checked_in_at, Time.now)
  end

  def get_user
    get("http://api.foursquare.com/v1/user.json")['user']
  end
end