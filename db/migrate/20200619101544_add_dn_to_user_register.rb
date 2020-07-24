class AddDnToUserRegister < ActiveRecord::Migration[6.0]
  def change
    add_column :user_registers, :dn, :string
  end
end
