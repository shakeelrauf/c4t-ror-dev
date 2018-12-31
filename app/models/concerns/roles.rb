module Roles
	def self.admin?
		self.roles == "admin"	
	end

	def self.user?
		self.roles == "user"
	end
end