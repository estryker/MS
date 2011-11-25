class AddGmapsColumnToSqueak < ActiveRecord::Migration
  def self.up
    add_column :squeaks, :gmaps, :boolean
  end

  def self.down
    remove_column :squeaks, :gmaps
  end
end
