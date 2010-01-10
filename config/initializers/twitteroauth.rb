class TwitterOauth
  
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
  
  def self.finish(request_token, oauth_verifier)
    final_request_token = OAuth::RequestToken.new(API, request_token[:token], request_token[:secret])
    final_request_token.get_access_token(:oauth_verifier => oauth_verifier)
  end
end