class AddDurationToSqueak < ActiveRecord::Migration
  def self.up
    add_column :squeaks, :duration, :integer
  end

  def self.down
    remove_column :squeaks, :duration
  end
end
