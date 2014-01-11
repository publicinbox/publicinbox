class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_name, :nil => false
      t.string :real_name
      t.string :password_digest

      t.timestamps
    end

    add_index :users, :user_name
  end
end
