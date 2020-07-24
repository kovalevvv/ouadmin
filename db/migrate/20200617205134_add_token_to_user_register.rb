class AddTokenToUserRegister < ActiveRecord::Migration[6.0]
  def change
    add_column :user_registers, :token, :string
  end
end
