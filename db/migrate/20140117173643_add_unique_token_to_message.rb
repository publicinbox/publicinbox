class AddUniqueTokenToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :unique_token, :string
    add_index :messages, :unique_token, :unique => true
  end
end
