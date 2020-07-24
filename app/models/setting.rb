# RailsSettings Model
class Setting < RailsSettings::Base
  cache_prefix { "v1" }

  # Define your fields
  field :self_host, type: :string, default: ENV.fetch("SELF_HOST")
  field :self_port, type: :string, default: ENV.fetch("SELF_PORT")
  field :host, type: :string, default: ENV.fetch("OUADMIN_HOST")
  field :port, type: :integer, default: ENV.fetch("OUADMIN_PORT")
  field :encryption, type: :boolean, default: ENV.fetch("OUADMIN_ENCRYPTION")
  field :account, type: :string, default: ENV.fetch("OUADMIN_ACCOUNT")
  field :account_password, type: :string, default: ENV.fetch("OUADMIN_ACCOUNT_PASSWORD")
  field :global_search_dn, type: :string, default: ENV.fetch("OUADMIN_GLOBAL_SEARCH_DN")
  field :global_search_port, type: :integer, default: ENV.fetch("OUADMIN_GLOBAL_SEARCH_PORT")
  field :ou_dn, type: :string, default: ENV.fetch("OUADMIN_OU_DN")
  field :subsystem_no, type: :array, default: [['СКВ: Jira& Confluence', 1], ['СКВ: Gitlab', 2], ['СКВ: Redmine', 3]]
  field :admin_group, type: :string, default: ENV.fetch("OUADMIN_ADMIN_GROUP")

  # field :default_locale, default: "en", type: :string
  # field :confirmable_enable, default: "0", type: :boolean
  # field :admin_emails, default: "admin@rubyonrails.org", type: :array
  # field :omniauth_google_client_id, default: (ENV["OMNIAUTH_GOOGLE_CLIENT_ID"] || ""), type: :string, readonly: true
  # field :omniauth_google_client_secret, default: (ENV["OMNIAUTH_GOOGLE_CLIENT_SECRET"] || ""), type: :string, readonly: true
end
