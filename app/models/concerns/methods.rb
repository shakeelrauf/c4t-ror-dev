module Methods
	extend ActiveSupport::Concern
	included do
		def self.find_by_id id
			self.send("find_by_id#{name}", id)
		end

    def self.run_sql_query(query, offset=nil , limit=nil)
			query += "Offset #{offset}" if offset.present?
			query += "Limit #{limit}" if limit.present?
			result = ActiveRecord::Base.connection.select_all(query)
			return  result
		end
	end
end