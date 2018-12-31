class User < ApplicationRecord
	self.table_name = 'Users'
	include Roles
	validates :email,  presence: true
 	validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
 	validates_length_of :password, minimum: 8

 	
 	def name
		name = self.firstName + ' ' + self.lastName;
	end

	def isValidPassword(password)
		return self.encrypt(password) == password
	end

	def self.encrypt text
	  text = text.to_s unless text.is_a? String

	  len   = ActiveSupport::MessageEncryptor.key_len
	  salt  = SecureRandom.hex len
	  key   = ActiveSupport::KeyGenerator.new(Rails.application.secret_key_base).generate_key salt, len
	  crypt = ActiveSupport::MessageEncryptor.new key
	  encrypted_data = crypt.encrypt_and_sign text
	  "#{salt}$$#{encrypted_data}"
	end

	private
	def decrypt_pw text
	  salt, data = text.split "$$"

	  len   = ActiveSupport::MessageEncryptor.key_len
	  key   = ActiveSupport::KeyGenerator.new(Rails.application.secret_key_base).generate_key salt, len
	  crypt = ActiveSupport::MessageEncryptor.new key
	  crypt.decrypt_and_verify data
	end
end

