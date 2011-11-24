class AddIndexToSqueaks < ActiveRecord::Migration
  def self.up
       
    add_index :squeaks, :user_email
    add_index :squeaks, :created_at
  end

  def self.down
  end
end
