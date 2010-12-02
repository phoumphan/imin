class AddDeltaIndex < ActiveRecord::Migration
  def self.up
    add_column :events, :delta, :boolean, :default => true, :null => false
    add_column :users, :delta, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :events, :delta
    remove_column :users, :delta
  end
end
