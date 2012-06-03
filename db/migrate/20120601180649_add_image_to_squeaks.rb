class AddImageToSqueaks < ActiveRecord::Migration

  def self.up
    add_column :squeaks, :image, :binary
  end

  def self.down
    remove_column :squeaks, :image
  end
end
