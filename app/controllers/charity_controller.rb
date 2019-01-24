class CharityController < ApplicationController
	# before_action :authenticate_user
	# before_action :authenticate_admin
   before_action :login_required

	def create
    res = ApiCall.post("/charities", form_body(params), headers )
    growl(response_msg(res), "create")
    redirect_to charities_path
	end

	def get_charities
    @charities = ApiCall.get("/charities",{}, headers)
	end

	def new
	end

	def edit
		@charitie = ApiCall.get("/charities/#{params[:no]}", {}, headers)
	end

	def update
    res = ApiCall.put("/charities/#{params[:id]}", form_body(params), headers)
    growl(response_msg(res), "update")
    redirect_to charities_path
  end

	private

	def form_body(params)
    {
      "name":      params[:name],
      "phone": 		 params[:phone],
      "email": 		 params[:email],
      "address": 	 params[:address],
      "info": 		 params[:info]
    }
  end

  def growl(res, action)
    notice = "Charity edited!"
    if action == "create"
      notice = "Charity added."
    end
    if res == true
      flash[:success] = notice
    else
      flash[:alert] = res
    end
  end

  def response_msg(res)
    result = ""
    if res["idCharitie"].present?
      result = true
    elsif res["errors"].present?
      result = res["errors"]
    end
    result
  end
end
