class AddOpenedAtToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :opened_at, :datetime
  end
end
