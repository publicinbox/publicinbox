class AddSourceIdToMessage < ActiveRecord::Migration
  def change
    # This will identify the e-mail a message is in *response* to.
    add_column :messages, :source_id, :integer

    add_index :messages, :source_id
  end
end
