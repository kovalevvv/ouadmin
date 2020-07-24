class CreateUserRegisters < ActiveRecord::Migration[6.0]
  def change
    create_table :user_registers do |t|
      t.string :firstname
      t.string :secondname
      t.string :lastname
      t.string :email
      t.integer :status, :default => 0

      t.timestamps
    end
  end
end
