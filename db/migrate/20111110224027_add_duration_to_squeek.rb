class AddDurationToSqueek < ActiveRecord::Migration
  def self.up
    add_column :squeeks, :duration, :integer
  end

  def self.down
    remove_column :squeeks, :duration
  end
end
