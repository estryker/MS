class AddGmapsColumnToSqueek < ActiveRecord::Migration
  def self.up
    add_column :squeeks, :gmaps, :boolean
  end

  def self.down
    remove_column :squeeks, :gmaps
  end
end
