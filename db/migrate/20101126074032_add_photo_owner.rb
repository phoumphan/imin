class AddPhotoOwner < ActiveRecord::Migration

  def self.up

    add_column :photos, :owner_id, :integer
  end



  def self.down
    remove_column :photos, :owner_id
  end
end
