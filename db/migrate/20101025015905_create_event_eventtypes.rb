class CreateEventEventtypes < ActiveRecord::Migration
  def self.up
    create_table :event_eventtypes do |t|
      t.integer :event_id
      t.integer :eventtype_id
      t.timestamps
    end
  end

  def self.down
    drop_table :event_eventtypes
  end
end
