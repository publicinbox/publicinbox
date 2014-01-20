class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_name, :nil => false
      t.string :email,     :nil => false
      t.string :real_name
      t.text   :bio

      # Allow the user to be notified at an external address when receiving
      # messages.
      t.string :external_email

      t.string :password_digest

      t.timestamps
    end

    add_index :users, :user_name, :unique => true
    add_index :users, :email,     :unique => true
  end
end
