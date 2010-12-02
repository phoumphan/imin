class PublicToString < ActiveRecord::Migration

  def self.up
    ActiveRecord::Base.connection().execute("ALTER TABLE events MODIFY public CHAR(7);")
    ActiveRecord::Base.connection().execute("UPDATE events SET public = 'Public' WHERE public = '1';")
    ActiveRecord::Base.connection().execute("UPDATE events SET public = 'Private' WHERE public = '0';")
  end



  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
