class ChangeEventsTable < ActiveRecord::Migration
  def self.up
    change_table :events do |t|
      t.remove :event_date
      t.remove :event_time
      t.datetime :start_at
      t.datetime :end_at
    end
  end

  def self.down
    change_table :events do |t|
      t.remove :start_at
      t.remove :end_at
      t.date :event_date
      t.time :event_time
    end
  end
end
