class PublicToString < ActiveRecord::Migration

  def self.up
    events = Event.all
    remove_column :events, :public
    add_column :events, :public, "CHAR(7)"
    events.each do |ev|
      if ev.public == 1
        ev.public = "Public"
      else
        ev.public = "Private"
      end
      ev.save!
    end
  end



  def self.down
    events = Event.all
    remove_column :events, :public
    add_column :events, :public, :integer
    events.each do |ev|
      if ev.public == "Public"
        ev.public = 1
      else
        ev.public = 0
      end
      ev.save!
    end
  end
end
