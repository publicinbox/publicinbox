class AddRealNameToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :real_name, :string
  end
end
