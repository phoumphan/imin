class CreateUserEvents < ActiveRecord::Migration
  def self.up
    create_table :user_events do |t|
      t.integer :user_id
      t.integer :event_id
      t.string :user_event_status
      t.timestamps
    end
  end

  def self.down
    drop_table :user_events
  end
end
