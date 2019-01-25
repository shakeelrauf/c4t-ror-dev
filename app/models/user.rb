class User < ApplicationRecord
	self.table_name = 'Users'
	include Roles
	validates :email,  presence: true
 	validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
 	validates_length_of :password, minimum: 8, message: "Password is too short"
	has_one :user_config
	has_many :authentications
	before_validation :validate_phone, :on => :create

	def validate_phone
		if attributes["phone"] != nil && attributes["phone"].length < 10
			self.errors.add(:phone, :invalid, message: "Phone Number must be greater than 10")
		end
	end

 	def name
		name = self.firstName + ' ' + self.lastName;
	end

	def is_valid_password?(password)
		return encrypt_pw(password) == self.password
	end

	def self.encrypt_token text
	  text = text.to_s unless text.is_a? String
	  len   = ActiveSupport::MessageEncryptor.key_len
	  salt  = SecureRandom.hex len
	  key   = ActiveSupport::KeyGenerator.new(Rails.application.secret_key_base).generate_key salt, len
	  crypt = ActiveSupport::MessageEncryptor.new key
	  encrypted_data = crypt.encrypt_and_sign text
	  "#{salt}$$#{encrypted_data}"
	end

	def self.encrypt(pass)
		Digest::SHA1.hexdigest(pass)
	end

	def encrypt_pw(pass)
		self.salt = make_salt if (self.salt.nil? || self.salt.blank?)
		Digest::SHA1.hexdigest(pass)
	end

	# Resets the password, return the plain text for emailing
	def reset_pw
		make_salt
		pass = SecureRandom.base64[0,6]
		self.password = encrypt_pw(pass)
    self.force_new_pw = true
    puts pass
		pass
	end

	def make_salt
		self.salt = SecureRandom.base64[0,10]
		self.salt
	end

	def cfg
		if (self.user_config.nil?)
			self.user_config = UserConfig.new
			self.user_config.save!
		end
		self.user_config
	end



	private
	def decrypt text
	  salt, data = text.split "$$"

	  len   = ActiveSupport::MessageEncryptor.key_len
	  key   = ActiveSupport::KeyGenerator.new(Rails.application.secret_key_base).generate_key salt, len
	  crypt = ActiveSupport::MessageEncryptor.new key
	  crypt.decrypt_and_verify data
	end
end

