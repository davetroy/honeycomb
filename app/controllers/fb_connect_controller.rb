class FbConnectController < ApplicationController

  def authenticate
    @user.facebook_user || @user.create_facebook_user
    @facebook_session = Facebooker::Session.create(Facebooker.api_key, Facebooker.secret_key)
    logger.debug "facebook session in authenticate: #{facebook_session.inspect}"
    redirect_to @facebook_session.login_url
  end

  def connect
    secure_with_token!
    session[:facebook_session] = @facebook_session
    logger.debug "facebook session in connect: #{facebook_session.inspect}"

    raise unless facebook_user
        
    unless user = FacebookUser.find_by_fb_uid(facebook_user.uid)
      facebook_user.email_hashes.find { |h| user = FacebookUser.find_by_email_hash(h) }
    end

    raise unless user
    user.update_attributes(:fb_uid => facebook_user.uid, :pic_square => facebook_user.pic_square, :name => facebook_user.name)
    login_user(user)
    redirect_to person_path(user.person)

  rescue Facebooker::Session::MissingOrInvalidParameter => e
    render :text => 'Got bad token!'
  rescue => e
    render :text => 'Connect failed!'
  end

  # callbacks, no session
  def post_authorize
    if linked_account_ids = params[:fb_sig_linked_account_ids].to_s.gsub(/\[|\]/,'').split(',')
      linked_account_ids.each do |user_id|
        if user = Person.find_by_id(user_id)
          user.facebook_user.create!(:fb_uid => params[:fb_sig_user])
        end
      end
    end

    render :nothing => true
  end
end
