class AddActivation < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
       t.column :activation_code, :string, :limit => 40
       t.column :activated_at, :datetime
    end
  end

  def self.down
    change_table :users do |t|
       t.remove :activation_code
       t.remove :activated_at
    end
  end
end
