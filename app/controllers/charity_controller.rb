class CharityController < ApplicationController
	before_action :authenticate_user
	before_action :authenticate_admin

	def create
		hou = Charitie.new(name: params[:name], phone: params[:phone], email: params[:email], address: params[:address], info: params[:info])
		hou.save!
		redirect_to '/charities'
	end

	def get_charities
		@charities = Charitie.all
	end

	def new
	end

	def edit
		@charitie =  Charitie.find_by_id params[:no]
	end

	def update
		hou = Charitie.where(idCharitie: params[:id])
		hou.first.update(name: params[:name], phone: params[:phone], email: params[:email], address: params[:address], info: params[:info])
		redirect_to '/charities'
	end

end
