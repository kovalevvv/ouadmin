class AddCompanyToUserRegister < ActiveRecord::Migration[6.0]
  def change
    add_column :user_registers, :company, :string
  end
end
