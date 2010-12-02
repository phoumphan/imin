class AddUserEventCreator < ActiveRecord::Migration

  def self.up

    add_column :user_events, :creator_id, :integer
  end



  def self.down

    remove_column :user_events, :creator_id
  end

end

