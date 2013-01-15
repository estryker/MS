class CreateSqueakChecks < ActiveRecord::Migration
  def change
    create_table :squeak_checks do |t|
      t.integer :squeak_id
      t.integer :user_id
      t.float :checked_from_latitude
      t.float :checked_from_longitude
      t.boolean :checked

      t.timestamps
    end
  end
end
