class Setting < ApplicationRecord
	self.table_name = 'settings'

	class << self
		def init_settings
			s1 = Setting.find_or_initialize_by(label: "steelPrice", name: "steelPrice")
			s1.new_record? ? s1.value=0 : ''
			s1.save!
			s2 = Setting.find_or_initialize_by(label: "freeDistance", name: "freeDistance")
			s2.new_record? ? s2.value=0 : ''
			s2.save!
			s3 = Setting.find_or_initialize_by(label: "excessPrice", name: "excessPrice")
			s3.new_record? ? s3.value=0 : ''
			s3.save!
			s4 = Setting.find_or_initialize_by(label: "catalysorPrice", name: "catalysorPrice")
			s4.new_record? ? s4.value=0 : ''
			s4.save!
			s5 = Setting.find_or_initialize_by(label: "wheelPrice", name: "wheelPrice")
			s5.new_record? ? s5.value=0 : ''
			s5.save!
			s6 = Setting.find_or_initialize_by(label: "batteryPrice", name: "batteryPrice")
			s6.new_record? ? s6.value=0 : ''
			s6.save!
		  s7 = Setting.find_or_initialize_by(label: "max_purchaser_increase", name: "max_purchaser_increase")
			s7.new_record? ? s1.value=20 : ''
			s7.save!
		  s8 = Setting.find_or_initialize_by(label: "max_increase_with_admin_approval", name: "max_increase_with_admin_approval")
			s8.new_record? ? s1.value=40 : ''
			s8.save!
			s = Setting.find_or_initialize_by(label: "bonus", name: "bonus", grade: "Bronze")
			s.new_record?  ? s.save! : ''
			s = Setting.find_or_initialize_by(label: "bonus-type", name: "bonus-type", grade: "Bronze")
			s.new_record?  ? s.save! : ''

			s = Setting.find_or_initialize_by(label: "bonus-1", grade: "Silver")
			s.new_record?  ? s.save! : ''

			s = Setting.find_or_initialize_by(label: "bonus-type-1", name: "bonus-type", grade: "Silver")
			s.new_record?  ? s.save! : ''

			s = Setting.find_or_initialize_by(label: "bonus-2", name: "bonus", grade: "Gold")
			s.new_record?  ? s.save! : ''

			s = Setting.find_or_initialize_by(label: "bonus-type-2", name: "bonus-type", grade: "Gold")
			s.new_record?  ? s.save! : ''

      s = Setting.find_or_initialize_by(label: "DealerFlatFee", name: "DealerFlatFee")
      s.new_record?  ? s.save! : ''

      s = Setting.find_or_initialize_by(label: "weight_year", name: "weight_year")
      s.new_record?  ? s.value=1994 : ''
			s.save
			return Setting.all
		end
	end
end
