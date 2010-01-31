# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def current_user
    @current_user
  end

  def facebook_session
    session[:facebook_session]
  end

  def facebook_user
    (session[:facebook_session] && session[:facebook_session].session_key) ? session[:facebook_session].user : nil
  end
  
  def format_date_range(r)
    "#{r.first.to_s(:short_date)} &ndash; #{r.last.to_s(:short_date)}"
  end
end
