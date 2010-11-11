class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :name
      t.text :description
      t.date :event_date
      t.time :event_time
      t.string :location
      t.integer :cost
      t.string :formality
      t.boolean :public
      t.integer :owner_id
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
