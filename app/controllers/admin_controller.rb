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
    @users_attrs = user_attrs.collect do |at| 
      { title: helpers.t("%s_%s" % ["label_user", at]) }
    end
  end

  def users
    @users = UserRegister.where(status: [1,2,3]).map do |user|
      entry = user.serializable_hash
      out = []
      user_attrs.each do |at|
        if at == "button"
          out << if user.created_account.present?
            user.created_account
          else
            helpers.link_to("Создать",new_user_from_user_path(user_id: user.id), :class => 'btn btn-primary')
          end
        else
          out << entry[at]
        end
      end
      out
    end
    render json: { data: @users }
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
        else
          user_unregistered = UserRegister.new(
            firstname: params.fetch(:givenName),
            secondname: params.fetch(:secondname),
            lastname: params.fetch(:sn),
            email: params.fetch(:mail),
            created_account: params.fetch(:sAMAccountName),
            status: 2,
            dn: @result.dn
          )
          user_unregistered.status = 3 if params[:whatodo] == 'enable_now'
          user_unregistered.token = SecureRandom.base58(24) if params[:whatodo] == 'enable_email'
          user_unregistered.save(:validate => false)
          
          if params[:whatodo] == 'enable_email'
            ApplicationMailer.user_set_password(user_unregistered).deliver_now
          end
        end
      rescue => e
        user ||= user_unregistered
        @@logger ||= Logger.new("#{Rails.root}/log/email.log")
        @@logger.info "#{user.email}"
        @@logger.debug e.message
        @email_result = 'ошибка отправки почты!!!' and return
      end
      if user or (user_unregistered and params[:whatodo] == 'enable_email')
        @email_result = 'письмо отправлено'
      end
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

    def user_attrs
      ["firstname", "lastname", "secondname", "phone", "company", "email", "button", "status", "sd"]
    end

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
