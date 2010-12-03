class ChangeEventPrivacy < ActiveRecord::Migration
  def self.up
    change_table :events do |t|
      t.remove :public
      t.string :privacy
    end
  end

  def self.down
    change_table :events do |t|
      t.remove :privacy
      t.boolean :public
    end
  end
end
