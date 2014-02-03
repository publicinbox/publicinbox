class AddDisplayInIframeToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :display_in_iframe, :boolean, :default => false
  end
end
