Rails.application.routes.draw do
  get 'registration', to: 'user_register#new'
  post 'registration', to: 'user_register#create'
  get 'confirmation/:token', to: 'user_register#confirmation', as: 'confirmation'
  get 'set_password/:token', to: 'user_register#set_password_form', as: 'set_password'
  post 'set_password/:token', to: 'user_register#set_password'
  get 'password_recovery', to: 'user_register#password_recovery_form', as: 'password_recovery'
  post 'password_recovery', to: 'user_register#password_recovery'
  root 'user_register#new'
  
  get 'admin/dashboard'
  post 'admin/search'
  get 'admin/new_user'
  get 'admin/new_user/:user_id', to: 'admin#new_user', as: 'new_user_from_user'
  post 'admin/new_user', to: 'admin#create_user'
  post 'admin/generate_or_check_logon'
  post 'admin/check_email'
  post 'admin/create_ou_user'

  get 'admin/login', to: 'admin#login', as: 'login'
  post 'admin/authorize', to: 'admin#authorize', as: 'authorize'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
