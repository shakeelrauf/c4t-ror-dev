class Authentication < ApplicationRecord
  belongs_to :user, optional: true
  before_save :generate_token

  protected
  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless self.class.where(token: random_token).exists?
    end
  end
end
