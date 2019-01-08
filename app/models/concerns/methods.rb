module Methods
	extend ActiveSupport::Concern
	included do
		def self.find_by_id id
			if ["Customer","Business"].include?(name)
				id_key = "Client"
			elsif name == "Heardofus"
				id_key = "HeardOfUs"
			elsif name == "QuoteCar"
				id_key = "QuoteCars"
			elsif name == "Setting"
				id_key = "Settings"
			elsif name == "VehicleInfo"
				id_key = "VehiculeInfo"
			else
				id_key = name
			end
			self.send("find_by_id#{id_key}", id)
		end

    def self.run_sql_query(query, offset=nil , limit=nil)
			query += " limit #{limit}" if limit.present?
			query += " offset #{offset}" if offset.present?
			result = ActiveRecord::Base.connection.select_all(query)
			return  result
		end
	end
end