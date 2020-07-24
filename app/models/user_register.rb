class UserRegister < ApplicationRecord
	validates :firstname, :lastname, :secondname, :email, :subsystem_no, :amenable, presence: true
	validates :email, confirmation: true
	validates :email_confirmation, presence: true, on: :create
	validates :email, uniqueness: { case_sensitive: false }
end
