class SettingController < ApplicationController

	# before_action :authenticate_user
	# before_action :authenticate_admin, only: [:all, :update]
	
	def settings
		last_settings = Setting.where("dtCreated IN (SELECT MAX(dtCreated) FROM Settings GROUP BY name)")
	end

	def all
		@settings = Setting.all
	end

	def update
		@settings = Setting.all
		@settings.each do |setting|
			if setting.name == "steelPrice"
				setting.value = params[:steelPrice]
			elsif setting.name == "freeDistance"
				setting.value = params[:freeDistance]
			elsif setting.name == "excessPrice"
				setting.value = params[:excessPrice]
			elsif setting.name == "catalysorPrice"
				setting.value = params[:catalysorPrice]
			elsif setting.name == "wheelPrice"
				setting.value = params[:wheelPrice]
			elsif setting.name == "batteryPrice"
				setting.value = params[:batteryPrice]
			elsif setting.label == "bonus"
				setting.value = params["--Bronze--bonus"]
			elsif setting.label == "bonus-type"
				setting.value = params["--Bronze--bonus-type"]
			elsif setting.label == "bonus-1"
				setting.value = params["--Silver--bonus"]
			elsif setting.label == "bonus-type-1"
				setting.value = params["--Silver--bonus-type"]
			elsif setting.label == "bonus-2"
				setting.value = params["--Gold--bonus"]
			elsif setting.label == "bonus-type-2"
				setting.value = params["--Gold--bonus-type"]
			end
			setting.save
		end
		flash[:notice] = 'Setting is successfully Updated!'
    redirect_to "/settings"
	end

	# def update
	# 	j = 0
	# 	l = params[:settings].length
	# 	params[:settings].each do |setting|
	# 		Setting.where(name: setting[:name], grade: setting[:grade])
	# 			.update_all(name: setting[:name],	label: setting[:name],
	# 			value: setting[:value],
	# 			grade: setting[:grade])
	# 			j+=1
	# 	end
	# 	return render_json_response({message: SETTING_UPDATE_MSG}, :ok) if (j >= l)
	# end
end