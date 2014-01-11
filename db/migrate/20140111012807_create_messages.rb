class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      # This is redundant, yes. But this way I don't need two separate tables
      # for outgoing/incoming messages.
      t.integer :sender_id
      t.string  :sender_email
      t.integer :recipient_id
      t.string  :recipient_email
      t.string  :subject
      t.text    :body

      t.timestamps
    end

    add_index :messages, :sender_id
    add_index :messages, :recipient_id
    add_index :messages, [:sender_id, :recipient_id]
    add_index :messages, [:recipient_id, :sender_id]
  end
end
