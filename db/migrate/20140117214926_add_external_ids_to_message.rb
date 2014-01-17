class AddExternalIdsToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :external_id, :string
    add_column :messages, :external_source_id, :string
    add_index :messages, :external_id
    add_index :messages, :external_source_id
  end
end
