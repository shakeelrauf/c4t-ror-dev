class CustomersController < ApplicationController
  # before_action :authenticate_user

  def index
    begin
      @customers = ApiCall.get("/clients",{})
    rescue Net::ReadTimeout
      @customers = []
    end
  end

  def show
    id = params[:id]
    begin
      @customer = ApiCall.get("/clients/#{id}",{no: id})
    rescue Net::ReadTimeout
      @customer = []
    end  
  end

end
