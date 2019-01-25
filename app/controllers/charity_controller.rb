class CharityController < ApplicationController
	# before_action :authenticate_user
	# before_action :authenticate_admin
  before_action :login_required
  before_action :set_charity , only: [:edit, :update]
  include Growl

	def create
    res = Charitie.new(charitie_params)
    res.save
    growl(response_msg(res, "idCharitie"), "create", "Charity")
    redirect_to charities_path
	end

	def get_charities
    @charities = Charitie.all
	end

	def new
	end

	def edit
    @charitie = Charitie.find(params[:no])
	end

	def update
    charitie = Charitie.find(params[:id])
    res = charitie.update(charitie_params)
    growl(res, "update", "Charity")
    redirect_to charities_path
  end

	private
  def set_charity
  end

  def charitie_params
    params.permit(:name, :email, :address, :phone, :info)
  end

end
