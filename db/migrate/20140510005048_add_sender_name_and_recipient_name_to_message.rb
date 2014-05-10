class AddSenderNameAndRecipientNameToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :sender_name, :string
    add_column :messages, :recipient_name, :string
  end
end
