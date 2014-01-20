class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string  :unique_token, :nil => false

      # This is redundant, yes. But this way I don't need two separate tables
      # for outgoing/incoming messages.
      t.integer :sender_id
      t.string  :sender_email
      t.integer :recipient_id
      t.string  :recipient_email

      # Maybe making these text columns is overkill. But it seems like these
      # groups might potentially be very large, so... why not?
      t.text    :cc_list
      t.text    :bcc_list

      # All messages are related to a 'thread' based on the originating
      # message's unique_token
      t.string  :thread_id

      # external_id is the Message-Id header supplied by an external provider
      # (e.g., Mailgun); external_source_id is the Message-Id header of the
      # message to which this message replies (if applicable)
      t.string  :external_id
      t.string  :external_source_id

      t.string  :subject
      t.text    :body
      t.text    :body_html

      t.datetime :opened_at
      t.datetime :archived_at

      t.timestamps
    end

    add_index :messages, :unique_token, :unique => true
    add_index :messages, :sender_id
    add_index :messages, :recipient_id
    add_index :messages, [:sender_id, :recipient_id]
    add_index :messages, [:recipient_id, :sender_id]
    add_index :messages, :thread_id
    add_index :messages, :external_id
    add_index :messages, :archived_at
  end
end
