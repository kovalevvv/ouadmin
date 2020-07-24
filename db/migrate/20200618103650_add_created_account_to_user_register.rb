class AddCreatedAccountToUserRegister < ActiveRecord::Migration[6.0]
  def change
    add_column :user_registers, :created_account, :string
  end
end
