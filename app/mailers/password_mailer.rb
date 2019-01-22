class PasswordMailer < ActionMailer::Base

  default from: 'from@example.com'
  layout 'mailer'

  def forget_password(user, reset_link)
  	@user = user
  	@reset_link = reset_link
    mail(to: @user.email, subject: 'Reset Password')
  end

end
