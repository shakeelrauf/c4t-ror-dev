module SettingHelper

	def label(name)
	  label = ""
	  if name == "steelPrice"
			label = t("settings.price_of_steel")
		elsif name == "freeDistance"
		  label = t("settings.free_distance")
		elsif name == "excessPrice"
		  label = t("settings.excess_of_distance")
		elsif name == "catalysorPrice"
		  label = t("settings.value_of_cata")
		elsif name == "wheelPrice"
		  label = t("settings.value_of_wheel")
		elsif name == "batteryPrice"
		  label = t("settings.value_of_bettery")
		elsif name == "DealerFlatFee"
			label = t("settings.door_price")
    elsif name == "weight_year"
      label = t('settings.weight_year')
    elsif name == "max_purchaser_increase"
      label = t('settings.max_purchaser_increase')
    elsif name == "max_increase_with_admin_approval"
      label = t('settings.max_increase_with_admin_approval')
		end
		label
	end
end
