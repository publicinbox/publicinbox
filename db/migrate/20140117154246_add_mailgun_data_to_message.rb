class AddMailgunDataToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :mailgun_data, :text
  end
end
