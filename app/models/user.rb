class User
	class << self

		def auth(logon, password)
			auth = Mos::initialize_ldap_con(logon, password)
	  	if auth.bind
	  		res = Mos::global_search(nil, Net::LDAP::Filter.eq("sAMAccountName", logon[/\\(.*)$/,1]))
	  		return logon if res.count == 1 and res[0].memberof.include?(Setting.admin_group)
	    end
		end

	end
end