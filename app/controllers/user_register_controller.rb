class UserRegisterController < ApplicationController

  def new
  	@user = UserRegister.new
  end

  def create
  	@user = UserRegister.new(user_params)
  	@user.token = new_token
  	if @user.save
  		begin
  			ApplicationMailer.user_register(@user).deliver_now
  		rescue => e
        @errors = [t(:mail_sent_error)]
        render :alert
  			elogger.info "#{@user.email}"
  			elogger.debug e.message
        @user.destroy
  		end
  	else
      @errors = @user.errors.messages.values.flatten
  		render :alert
  	end
  end

  def confirmation
  	if @user = params[:token].blank? ? false : UserRegister.where(:token => params[:token]).take
  		@user.status = 1
  		@user.token = nil
  		if @user.save
  			# sd?
        # {
        #   "ditMFSMAPI": {
        #      "Action": "create",
        #      "Filename": "Обращение",
        #      "ParamsNames": ["Шаблон", "Поле: Краткое описание", "Поле: Описание", "Поле: Email заявителя", "Поле: ФИО заявителя"],
        #      "ParamsValues": ["Template-SKV-zni-Dostup", "Новое оброщение", "Чудно" , "derats@gmail.com", "Ковалев Владимир Викторович"]
        #   }
        # }
  		else
				render :status => 503
  		end
  	else
  		render :status => 404
  	end
  end

  def set_password_form
  end

  def set_password
    @finalize_registration = UserPassword.new(set_password_params)
    unless @finalize_registration.valid?
      @errors = @finalize_registration.errors.full_messages
      render :alert
    else
      @result = @finalize_registration.set_password
    end
  end

  def password_recovery_form
  end

  def password_recovery
    if params[:email] =~ /@/
      @user = UserRegister.where(:email => params[:email], status: 3).take
      # а не проверить ли соответсвие почты в лдап?
    else
      @user = UserRegister.where(:created_account => params[:email], status: 3).take
    end
    if @user
      @user.update_columns(token: new_token)
      begin
        ApplicationMailer.user_set_password(@user).deliver_now
        # !!! восстановит заблокированного пользователя
      rescue => e
        elogger.info "#{@user.email}"
        elogger.debug e.message
        @errors = [t(:mail_sent_error)]
        render :alert
      end
    else
      @errors = ['Пользователя не существует или регистрация не завершена']
      render :alert
    end
  end

  private

  def elogger
    @@logger ||= Logger.new("#{Rails.root}/log/email.log")
  end

  def new_token
    SecureRandom.base58(24)
  end 

  def user_params
    params.require(:user_register).permit(:firstname, :lastname, :secondname, :email, :email_confirmation, :amenable, :subsystem_no)
  end

  def set_password_params
    params.permit(:password, :password_confirmation, :token)
  end

end
