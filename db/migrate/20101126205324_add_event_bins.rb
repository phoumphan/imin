class AddEventBins < ActiveRecord::Migration

  def self.up

    add_column :events, :bin_lat, :integer
    add_column :events, :bin_lng, :integer

    events = Event.all
    events.each do |ev|
      binvals = UsersController.hash_loc ev.location
      ev.bin_lat = binvals[0]
      ev.bin_lng = binvals[1]
      ev.save
    end
  end

  def self.down

    remove_column :events, :bin_lat
    remove_column :events, :bin_lng
  end
end

