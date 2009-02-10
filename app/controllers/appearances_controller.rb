class AppearancesController < ApplicationController
  
  def index
    @appearances = Appearance.today
  end
  
end
