class CreateEventRating < ActiveRecord::Migration
  def self.up
    create_table :event_ratings do |t|
      t.integer :event_id
      t.integer :user_id
      t.integer :rating
      t.timestamps
    end
  end

  def self.down
    drop_table :event_ratings
  end
end
