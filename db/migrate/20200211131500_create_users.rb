class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :second_name
      t.string :email
      t.string :phone
      t.string :company
      t.string :created_account
      t.string :status
      t.string :sd

      t.timestamps
    end
  end
end
