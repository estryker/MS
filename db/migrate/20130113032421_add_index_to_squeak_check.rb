class AddIndexToSqueakCheck < ActiveRecord::Migration
  def change
    add_index :squeak_checks, [:squeak_id, :user_id], :unique => true
  end
end
