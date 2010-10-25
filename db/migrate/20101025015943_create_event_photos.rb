class CreateEventPhotos < ActiveRecord::Migration
  def self.up
    create_table :event_photos do |t|
      t.integer :event_id
      t.integer :photo_id
      t.boolean :default_photo
      t.timestamps
    end
  end

  def self.down
    drop_table :event_photos
  end
end
