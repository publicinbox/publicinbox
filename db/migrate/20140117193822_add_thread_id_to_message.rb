class AddThreadIdToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :thread_id, :string
    add_index :messages, :thread_id
  end
end
