class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAIL_FROM')
  layout 'mailer'
  self.raise_delivery_errors = true

  def user_register(user)
  	@user = user
    mail(to: @user.email, subject: 'User register')
  end

  def user_set_password(user)
  	@user = user
  	mail(to: @user.email, subject: 'User set password link')
  end

end
