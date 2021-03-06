module Settings
  def update_settings
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
      elsif setting.name == "DealerFlatFee"
        setting.value = params[:DealerFlatFee]
      elsif setting.name == "weight_year"
        setting.value = params[:weight_year]
      elsif setting.name == "max_purchaser_increase"
        setting.value = params[:max_purchaser_increase]
      elsif setting.name == "max_increase_with_admin_approval"
        setting.value = params[:max_increase_with_admin_approval]
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
  end
end