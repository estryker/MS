class AddUserEmailToSqueak < ActiveRecord::Migration
  def self.up
    add_column :squeaks, :user_email, :string
  end

  def self.down
    remove_column :squeaks, :user_email
  end
end
