class AddUserEmailToSqueek < ActiveRecord::Migration
  def self.up
    add_column :squeeks, :user_email, :string
  end

  def self.down
    remove_column :squeeks, :user_email
  end
end
