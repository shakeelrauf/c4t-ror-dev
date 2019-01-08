class UserConfig < ApplicationRecord
  belongs_to :user

  def reinit_pw
    self.pw_reinit_key = SecureRandom.hex
    self.pw_reinit_exp = Time.now + 1.day
    self.user.save!
  end

  def reinit_clear
    self.pw_reinit_key = nil
    self.pw_reinit_exp = nil
  end

  def pw_init_valid?(key)
    return false if (self.pw_reinit_key.nil? || self.pw_reinit_exp.nil?)
    return false if key.nil?
    return false if (key != self.pw_reinit_key)
    return (((Time.now <=> self.pw_reinit_exp) == -1) && (key == self.pw_reinit_key))
  end
end
