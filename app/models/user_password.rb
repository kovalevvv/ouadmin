class UserPassword
	include ActiveModel::Validations
	include ActiveModel::Conversion
  extend ActiveModel::Naming

	attr_accessor :password
	attr_accessor :token

	validates :password, format: { 
		with: /\A(?=.{8,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[[:^alnum:]])/, 
		message: "must include at least one lowercase letter, one uppercase letter, and one digit и символ" 
	}

	validates :password, confirmation: true
	validates :password_confirmation, presence: true
	validates :token, presence: true

	def persisted?
    false
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def logger
		@@logger ||= Logger.new(STDOUT)
	end

  def user
  	@user ||= UserRegister.where(token: self.token).take if self.valid?
  end

  def set_password
  	if self.valid? and self.user.class.name == 'UserRegister'
  		ldap = Mos::initialize_ldap_con(Setting.account, Setting.account_password, port: Setting.port)
  		ldap.modify(:dn => self.user.dn, :operations => [[:replace, :useraccountcontrol, '544']])
			logger.info "SET_PASSWORD (#{self.user.created_account}) useraccountcontrol #{ldap.get_operation_result}"		
			ldap.modify(:dn => self.user.dn, :operations => [[:replace, :pwdlastset, '-1']])
			logger.info "SET_PASSWORD (#{self.user.created_account}) pwdlastset #{ldap.get_operation_result}"
  		ldap.modify(
  			:dn => self.user.dn, 
  			:operations => [[:replace, :unicodePwd, Mos::str2unicodePwd(self.password)]]
  		)
			logger.info "SET_PASSWORD (#{self.user.created_account}) userPassword #{ldap.get_operation_result}"
			if ldap.get_operation_result.code == 0
				self.user.update_columns(
        token: nil,
        status: 3)
			end
			ldap.get_operation_result.message
		else
			"internal error"
		end
  end

end