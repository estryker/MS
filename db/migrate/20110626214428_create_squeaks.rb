class CreateSqueaks < ActiveRecord::Migration
  def self.up
    create_table :squeaks do |t|
      t.float :latitude
      t.float :longitude
      t.datetime :time_utc
      t.string :text
      t.datetime :expires

      t.timestamps
    end
 
  end

  def self.down
    drop_table :squeaks
  end
end
