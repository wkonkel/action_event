class CreateActionEventTables < ActiveRecord::Migration
  def self.up
    ActionEvent::Message.connection.create_table(:action_event_messages) do |t|
      t.string :event, :null => false
      t.text :params
      t.timestamps
    end
    
    ActionEvent::Message.connection.create_table(:action_event_statuses) do |t|
      t.integer :last_processed_message_id, :null => false
      t.string :table_name, :null => false
      t.timestamps
    end
    
    ActionEvent::Message.connection.add_index :action_event_statuses, :table_name, :unique => true
  end

  def self.down
    ActionEvent::Message.connection.drop_table :action_event_messages
    ActionEvent::Message.connection.drop_table :action_event_statuses
  end
end
