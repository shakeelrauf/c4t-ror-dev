class Charitie < ApplicationRecord
	self.table_name = "Charities"
	validates :phone, presence: true, format: { with: /[0-9]*/ }, length: { minimum: 10 }
	validates :email, presence: true, format: { with: /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/ }
	before_save :set_phone_format 
	
	def set_phone_format
		if self.phone.length == 10
    	self.phone = self.phone[0..2] + " " + self.phone[3..5] + "-" + self.phone[6..-1]
  	elsif phone.length == 11
    	self.phone =  self.phone[0] + "-" + self.phone[1..3] + " " + self.phone[4..6] + "-" + self.phone[7..-1]
    end
	end
end
