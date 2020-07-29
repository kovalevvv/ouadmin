class AdminController < ApplicationController
  before_action :user_logged?, except: [:login, :authorize]
  layout "user_register", only: :login

  def login
    reset_session
  end

  def authorize
    reset_session
    begin
      if user = User::auth(params[:logon], params[:password])
        session[:logon] = user
        session[:password] = params[:password]
        session[:updated_at] = Time.current
        redirect_to admin_dashboard_url
      else
        redirect_to login_url
      end
    rescue => e
      Mos.logger.info "Authorize: #{e.message}"
      redirect_to login_url
    end
  end

  def dashboard
  	@users = UserRegister.where(status: [1,2,3])
  end

  def search
  	@users = Mos.global_search(params[:q]) || []
  end

  def new_user
    if params[:user_id] and UserRegister.find(params[:user_id])
      @user = UserRegister.where(id: params[:user_id], status: 1).take
    end
  end

  def create_ou_user
    user = UserRegister.find(params[:user_id]) if params[:user_id]
  	@result = Mos.add(params, user)
    if @result.code == 0
      begin
        if user
          ApplicationMailer.user_set_password(user).deliver_now
        elsif params[:send_email]
          user = UserRegister.new(
            firstname: params.fetch(:givenName),
            secondname: params.fetch(:secondname),
            lastname: params.fetch(:sn),
            email: params.fetch(:mail),
            status: -1,
            token: SecureRandom.base58(24),
            dn: @result.dn
          )
          user.save(:validate => false)
          ApplicationMailer.user_set_password(user).deliver_now
        end
      rescue => e
        @@logger ||= Logger.new("#{Rails.root}/log/email.log")
        @@logger.info "#{user.email}"
        @@logger.debug e.message
        @email_result = 'ошибка отправки почты!!!' and return
      end
      @email_result = 'письмо отправлено'
    end
  end

  def generate_or_check_logon
  	if params[:sAMAccountName].blank?
  		if params[:givenName].present? && params[:sn].present? && params[:secondname].present?
  			begin
          new_logon = Mos.make_new_logon(
    										firstname: params[:givenName],
    										lastname: params[:sn],
    										secondname: params[:secondname]
    									)
        rescue
          render js: "alert('контроллер домена не отвечает')" and return
        end
  			render js: "$('#logonname').val('#{new_logon}').removeClass('is-invalid').addClass('is-valid')"
  		else
  			render js: "$('#logonname').removeClass('is-valid').addClass('is-invalid')"
  		end
  	else
      begin
    		if Mos.logon_busy? params[:sAMAccountName].strip
    			render js: "$('#logonname').removeClass('is-valid').addClass('is-invalid')"
    		else
    			render js: "$('#logonname').removeClass('is-invalid').addClass('is-valid')"
    		end
      rescue
        render js: "alert('контроллер домена не отвечает')"
      end
  	end
  end

  def check_email
  	if params[:mail].present? && params[:mail] =~ /@/
      begin
    		if Mos.mail_busy? params[:mail].strip
    			render js: "$('#email').removeClass('is-valid').addClass('is-invalid'); var email_validate = false"
    		else
    			render js: "$('#email').removeClass('is-invalid').addClass('is-valid'); var email_validate = true"
    		end
      rescue
        render js: "alert('контроллер домена не отвечает')"
      end
  	else
  		render js: "$('#email').removeClass('is-valid').addClass('is-invalid'); var email_validate = false"
  	end
  end

  private

    def user_logged?
      redirect_to login_url if user_current.nil?
    end

    def user_current
      begin
        if session[:logon] and session[:password] and (Time.current.to_time - session[:updated_at].to_time).seconds < 5.minutes.seconds
          session[:updated_at] = Time.current
          Rails.cache.fetch("#{session[:logon]}", expires_in: 5.minutes) do
            User::auth(session[:logon], session[:password])
          end
        end
      rescue => e
        Mos.logger.info "Authorize current user: #{e.message}"
        nil
      end
    end

end
