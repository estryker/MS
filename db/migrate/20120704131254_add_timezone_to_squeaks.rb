class AddTimezoneToSqueaks < ActiveRecord::Migration
 def self.up
    add_column :squeaks, :timezone, :string
  end

  def self.down
    remove_column :timezone
  end
end
