class AddChangesToUserRegister < ActiveRecord::Migration[6.0]
  def change
    add_column :user_registers, :subsystem_no, :integer
    add_column :user_registers, :amenable, :string
  end
end
