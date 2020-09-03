class Mos

	class << self

		def logger
			@@logger ||= Logger.new(STDOUT)
		end

		def initialize_ldap_con(ldap_user, ldap_password, options={})
	    options = { :host => Setting.host,
	                :port => Setting.port,
	                :encryption => (Setting.encryption ? { 
	                	:method => :simple_tls
	                	
	                } : nil)
	              }.merge!(options)
	    options.merge!(:auth => { :method => :simple, :username => ldap_user, :password => ldap_password }) unless ldap_user.blank? && ldap_password.blank?
	    Net::LDAP.new options
	  end

	  def global_ldap
	  	@@ldap_con ||= self::initialize_ldap_con(Setting.account, Setting.account_password, port: Setting.global_search_port, encryption: nil)
	  end

	  def ldap
	  	@@ldap ||= self::initialize_ldap_con(Setting.account, Setting.account_password, port: Setting.port)
	  end

		def global_search(q, filter=nil)
			search_filter = filter.nil? ? Net::LDAP::Filter.eq("sAMAccountName", q) | 
											Net::LDAP::Filter.eq("displayName", q) |
											Net::LDAP::Filter.eq("name", q) | 
											Net::LDAP::Filter.eq("mail", q) : filter
			result_attrs = ["sAMAccountName", "displayName", "mail", "name", "givenName", "sn", "memberof"]
			global_ldap.search(:base => Setting.global_search_dn, :filter => search_filter, :attributes => result_attrs, :return_result => true)
		end

		def search_by_attribute(at, q)
			search_filter = Net::LDAP::Filter.eq(at, q)
			result = []
			global_ldap.search(:base => Setting.global_search_dn, :filter => search_filter, :attributes => [at], :return_result => false) do |entry|
				result << self::get_attr(entry, at)
			end
			logger.info global_ldap.get_operation_result
			result
		end

		def str2unicodePwd(str)
    	('"' + str + '"').encode("utf-16le").force_encoding("utf-8")
  	end

		def add(params = {}, user_register = nil)
			params.transform_values!(&:strip)
			cn = "#{params.fetch(:sn)} #{params.fetch(:givenName)} #{params.fetch(:secondname)}"
			dn = "CN=#{cn},#{Setting.ou_dn}"
			user = {
			  :cn => cn,
			  :displayName => cn,
			  :sAMAccountName => params.fetch(:sAMAccountName),
			  :givenName => params.fetch(:givenName),
			  :objectClass => ["top", "person", "user", "organizationalPerson"],
			  :userPrincipalName => "#{params.fetch(:sAMAccountName)}@ext.corp.mos.ru",
			  :sn => params.fetch(:sn),
			  :description => 'SD0000000'
			}
			user.merge!({:mail => params.fetch(:mail)}) if params.fetch(:mail).present?

			logger.info user
			logger.info dn

			if user_register			
				ldap.add(:dn => dn, :attributes => user)
				logger.info "CREATE #{ldap.get_operation_result}"		 
				if ldap.get_operation_result.code == 0
					user_register.update_columns(
						dn: dn,
		        created_account: params.fetch(:sAMAccountName),
		        token: SecureRandom.base58(24),
		        status: 2
		       )
					if params.fetch(:mail).present? # override email only
						user_register.update_columns email: params.fetch(:mail)
					end
				end
				return ldap.get_operation_result
			end

			os = OpenStruct.new
			ldap.add(:dn => dn, :attributes => user)
			os = return_messages(os, ldap, "CREATE")
			if params.fetch(:whatodo) == 'enable_now' and os.code == 0
				ldap.modify(:dn => dn, :operations => [[:replace, :useraccountcontrol, '544']])
				os = return_messages(os, ldap, "UPDATE useraccountcontrol")
				if os.code == 0
					ldap.modify(:dn => dn, :operations => [[:replace, :pwdlastset, '-1']])
					os = return_messages(os, ldap, "UPDATE pwdlastset")
				else
					ldap.delete :dn => dn
					os = return_messages(os, ldap, "DELETE")
				end
				if os.code == 0
					ldap.modify(:dn => dn, :operations => [[:replace, :unicodePwd, self::str2unicodePwd(params.fetch(:userPassword))]])
					os = return_messages(os, ldap, "UPDATE userPassword")
				else
					ldap.delete :dn => dn
					os = return_messages(os, ldap, "DELETE")
				end
				unless os.code == 0 # if password error
					ldap.delete :dn => dn
					os = return_messages(os, ldap, "DELETE")
				end
			end
			os.dn = dn
			os
		end

		def return_messages(os, ldap, prefix)
			message = "#{prefix}: #{ldap.get_operation_result.error_message.present? ? ldap.get_operation_result.error_message : ldap.get_operation_result.message}"
			logger.info message
			os.code = ldap.get_operation_result.code if os.code == 0 || os.code.nil?
			os.message = os.message.nil? ? "#{message} <br/>".html_safe : os.message + "#{message} <br/>".html_safe
			os
		end

		def search_free_logon(logon)
			if self::logon_busy?(logon)
				busy = self::search_by_attribute("sAMAccountName", "#{logon}*")
				(1..100).each do |i|
					new_logon = "#{logon}#{i}"
					return new_logon unless busy.include?(new_logon)
				end
			else
				logon
			end
		end

		def make_new_logon(firstname:, lastname:, secondname:)
			if firstname.strip.present? && lastname.strip.present? && secondname.strip.present?
				desired_logon = "#{lastname.strip.capitalize}#{firstname.strip.first.upcase}#{secondname.strip.first.upcase}".to_lat
				self::search_free_logon(desired_logon)
			else
				""
			end
		end

		def mail_busy?(email)
			self::search_by_attribute("mail", email).include?(email)
		end

		def logon_busy?(logon)
			self::search_by_attribute("sAMAccountName", logon).include?(logon)
		end

		def get_attr(entry, attr_name)
	    if !attr_name.blank?
	      entry[attr_name].is_a?(Array) ? entry[attr_name].first : entry[attr_name]
	    end
  	end

	end
end