class AddPasswordResetCode < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :password_reset_code,       :limit => 40
    end

  end

  def self.down
    change_table :users do |t|
      t.remove :password_reset_code
    end
  end
end
