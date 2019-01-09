class SettingController < ApplicationController

	# before_action :authenticate_user
	# before_action :authenticate_admin, only: [:all, :update]
	 before_action :login_required

	def settings
		last_settings = Setting.where("dtCreated IN (SELECT MAX(dtCreated) FROM Settings GROUP BY name)")
	end

	def all
    @edited = false || params[:edited]
		@settings = ApiCall.get("/settings",{}, headers)
	end

	def update
		@settings = ApiCall.put("/settings", JSON.parse(params.to_json), headers)
		flash[:notice] = 'Setting is successfully Updated!'
    redirect_to controller: 'setting', action: 'all', edited: true
	end

end