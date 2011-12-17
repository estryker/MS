class IndexLatAndLong < ActiveRecord::Migration
  def up
    add_index :squeaks, :latitude
    add_index :squeaks, :longitude
  end

  def down
    remove_index :squeaks,:column => :latitude
    remove_index :squeaks,:column => :longitude    
  end
end
