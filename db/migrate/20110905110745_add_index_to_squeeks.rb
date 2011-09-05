class AddIndexToSqueeks < ActiveRecord::Migration
  def self.up
       
    add_index :squeeks, :user_email
    add_index :squeeks, :created_at
  end

  def self.down
  end
end
