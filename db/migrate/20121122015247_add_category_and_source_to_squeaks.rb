class AddCategoryAndSourceToSqueaks < ActiveRecord::Migration
  def self.up
    add_column :squeaks, :category, :string
    add_column :squeaks, :source, :string
  end

  def self.down
    remove_column :category
    remove_column :source
  end
end
