class User < ApplicationRecord
	self.table_name = 'Users'

	def name
		name = self.firstName + ' ' + self.lastName;
	end

	def isValidPassword(password)
    return(hasher.verify(password, this.password));	
	end
end
