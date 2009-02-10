class AppearancesController < ApplicationController
  
  def index
    @appearances = Appearance.current
  end
  
end
