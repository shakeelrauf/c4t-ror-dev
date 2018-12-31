module Methods
	extend ActiveSupport::Concern
	included do
		def self.find_by_id id
			self.send("find_by_id#{name}", id)
		end
	end
end