class AddUseridToSqueak < ActiveRecord::Migration
  def self.up
    add_column :squeaks, :user_id, :integer
  end

  def self.down
    remove_column :squeaks, :user_id
  end
end
