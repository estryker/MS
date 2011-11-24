class CreateSqueeks < ActiveRecord::Migration
  def self.up
    create_table :squeeks do |t|
      t.float :latitude
      t.float :longitude
      t.datetime :time_utc
      t.string :text
      t.datetime :expires

      t.timestamps
    end
 
  end

  def self.down
    drop_table :squeeks
  end
end
