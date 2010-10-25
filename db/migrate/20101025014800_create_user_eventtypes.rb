class CreateUserEventtypes < ActiveRecord::Migration
  def self.up
    create_table :user_eventtypes do |t|
      t.integer :user_id
      t.integer :eventtype_id
      t.integer :rating
      t.timestamps
    end
  end

  def self.down
    drop_table :user_eventtypes
  end
end
