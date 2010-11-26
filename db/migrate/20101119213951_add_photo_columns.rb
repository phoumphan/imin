# Based on https://github.com/thoughtbot/paperclip

class AddPhotoColumns < ActiveRecord::Migration


  def self.up
    remove_column :photos, :photo_url
    add_column :photos, :photo_file_name,    :string
    add_column :photos, :photo_content_type, :string
    add_column :photos, :photo_file_size,    :integer
    add_column :photos, :photo_updated_at,   :datetime
  end

  def self.down
    add_column :photos, :photo_url,       :string
    remove_column :photos, :photo_file_name
    remove_column :photos, :photo_content_type
    remove_column :photos, :photo_file_size
    remove_column :photos, :photo_updated_at
  end
end
