class AddAutomatedToUser < ActiveRecord::Migration
  def change
    add_column :users, :automated, :boolean
  end
end
