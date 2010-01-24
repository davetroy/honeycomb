module OauthMethods
  private
  def access_token
    OAuth::AccessToken.new("#{self.class}::API".constantize, self.token, self.secret)
  end

  def get(url)
    JSON.parse(access_token.get(url).body)
  end

  def post(url)
    JSON.parse(access_token.post(url).body)
  end
end