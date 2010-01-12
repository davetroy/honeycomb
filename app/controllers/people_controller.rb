class PeopleController < ApplicationController
  before_filter :authenticate
  
  def confirm_device_for
    if (@person = Person.find(params[:id])) && (@device = Device.find(params[:device_id]))
      @device.update_attribute(:person_verified, true) if (@device.person_id == @person.id && @device.confirmation_key == params[:key])
      flash.now[:notice] = "Device #{@device.mac} has been claimed by #{@person.email}!"
    end
    
    if @person.is_setup?
      redirect_to root_path
    else
      redirect_to edit_person_path(@person, :key => @person.temporary_key)
    end
  end

  def edit
    render :status => 404 unless session[:person_id]
  end
  
  def update
    @person.update_attributes(params[:person])
    flash.now[:notice] = "Updates saved!"
    redirect_to root_path
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
    end
  end
  
end