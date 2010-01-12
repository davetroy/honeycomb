class PeopleController < ApplicationController
  before_filter :authenticate, :except => :logout
  
  def confirm_device_for
    if (@person = Person.find(params[:id])) && (@device = Device.find(params[:device_id]))
      @device.update_attribute(:person_verified, true) if @device.person_id == @person.id
      flash.now[:notice] = "Device #{@device.mac} has been claimed by #{@person.email}!"
    end
    
    if @person.is_setup?
      redirect_to root_path
    else
      redirect_to edit_person_path(@person, :key => @person.temporary_key)
    end
  end

  def edit
  end
  
  def update
    pparams = params[:person]
    if pparams[:password]
      if pparams[:password]==pparams[:password_confirmation]
        pparams[:password_hash] = Digest::MD5.hexdigest(pparams[:password])
        [:password, :password_confirmation].each { |a| pparams.delete(a) }
      else
        flash.now[:notice] = "Password did not match!"
        render :reset_password
      end
    end 
    @person.update_attributes(pparams)
    flash.now[:notice] = "Updates saved!"
    redirect_to person_path
  end
  
  # member directory
  def index
    @people = Person.find(:all).sort { |a,b| b.days.size <=> a.days.size }
  end
  
  def show
    if @person.id == session[:person_id]
      render params[:type] if params[:type]
    else
      render 'show_public'
    end
  end
    
  def destroy
    @person.destroy
    redirect_to people_path
  end
  
  def email_password
    PersonMailer.deliver_login_link(@person)
    flash.now[:notice] = "Sent login link to #{@person.email}"
    render 'show_public'
  end
  
  def authenticate
    if params[:id]
      @person = Person.find(params[:id])
      if params[:key]
        if params[:key] == @person.temporary_key
          session[:person_id] = @person.id
        else
          session[:person_id] = nil
          render :status => 404
        end
      end
      
      if params[:person] && params[:person][:password]
        if Digest::MD5.hexdigest(params[:person][:password])==@person.password_hash
          session[:person_id] = @person.id
        else
          session[:person_id] = nil
        end
      end
      
    end
  end
  
  def logout
    session[:person_id] = nil
    redirect_to people_path
  end
  
  # Login as a particular user
  def login
    render :reset_password if session[:person_id]==@person.id
  end
  
  def confirm_login
    redirect_to person_path(@person)
  end
  
end