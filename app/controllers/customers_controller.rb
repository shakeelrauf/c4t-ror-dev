class CustomersController < ApplicationController

  def index
    begin
      @customers = ApiCall.get("/clients",{})
    rescue Net::ReadTimeout
      @customers = []
    end
  end

end
