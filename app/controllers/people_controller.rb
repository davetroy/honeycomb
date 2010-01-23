class PeopleController < ApplicationController
  before_filter :load_person

  def confirm_device_for
    @device = Device.find(params[:device_id])
    if @device && (@device.person_id == @person.id)
      @device.update_attribute(:person_verified, true) 
      flash.now[:notice] = "Device #{@device.mac} has been claimed by #{@person.email}!"
    else
      flash.now[:notice] = "Device has been claimed by another user!"
    end
    
    redirect_to @person.is_setup? ? root_path : edit_person_path(@person, :key => @person.temporary_key)
  end

  def edit
    redirect_to person_path(@person) if @person.id != session[:person_id]
  end
  
  def update
    store_password(params[:person])
    if @person.update_attributes(params[:person])
      flash[:notice] = 'Updates saved!'
      redirect_to person_path
    else
      render :action => 'edit'
    end
  end
  
  # member directory
  def index
    # TODO: cache sort on this
    @people = Person.find(:all, :include => :devices) #.sort { |a,b| b.days.size <=> a.days.size }
  end
  
  def show
    if @person.id == session[:person_id]
      render params[:type] if params[:type]
    else
      render 'show_public'
    end
  end
    
  # def destroy
  #   @person.destroy
  #   redirect_to people_path
  # end
  
  def email_password
    PersonMailer.deliver_login_link(@person)
    flash.now[:notice] = "Sent login link to #{@person.email}"
    render 'show_public'
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
    authenticate_person
    redirect_to person_path(@person)
  end
  
  private
  def load_person
    @person = Person.find(params[:id]) if params[:id]
  end
  
  def store_password(pparams)
    return unless pparams[:password]
    if pparams[:password]==pparams[:password_confirmation]
      pparams[:password_hash] = Digest::MD5.hexdigest(pparams[:password])
      [:password, :password_confirmation].each { |a| pparams.delete(a) }
    else
      flash.now[:notice] = "Password did not match!"
      render :reset_password
    end
  end
  
  
end