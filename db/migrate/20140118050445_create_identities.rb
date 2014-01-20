class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.integer :user_id,     :nil => false
      t.string  :provider,    :nil => false
      t.string  :provider_id, :nil => false
      t.string  :name
      t.string  :real_name
      t.string  :email
    end

    add_index :identities, :user_id
    add_index :identities, [:provider, :provider_id], :unique => true
  end
end
