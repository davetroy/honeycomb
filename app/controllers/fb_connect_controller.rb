class FbConnectController < ApplicationController

  def authenticate
    @user.facebook_user || @user.create_facebook_user
    @facebook_session = Facebooker::Session.create(Facebooker.api_key, Facebooker.secret_key)
    logger.debug "facebook session in authenticate: #{facebook_session.inspect}"
    redirect_to @facebook_session.login_url
  end

  def connect
    begin
      secure_with_token!
      session[:facebook_session] = @facebook_session
      logger.debug "facebook session in connect: #{facebook_session.inspect}"

      if facebook_user
        if user = FacebookUser.find_by_fb_uid(facebook_user.uid)
          login_user(user)
          return redirect_to person_path(user.person)
        end

        # not a linked user, try to match a user record by email_hash
        facebook_user.email_hashes.find do |hash|
          if user = FacebookUser.find_by_email_hash(hash)
            user.update_attribute(:fb_uid, facebook_user.uid)
            login_user(user)
            return redirect_to person_path(user.person)
          end
        end
      end

    # it seems sometimes facebook gives us a useless auth token, so retry
    rescue Facebooker::Session::MissingOrInvalidParameter => e
      return render :text => 'Got bad token!' # redirect_to(:action => 'authenticate')
    end

    render :text => 'Connect failed!'  # (:nothing => true)
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
