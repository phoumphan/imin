class CreateEventtypes < ActiveRecord::Migration
  def self.up
    create_table :eventtypes do |t|
      t.string :description
      t.timestamps
    end
  end

  def self.down
    drop_table :eventtypes
  end
end
