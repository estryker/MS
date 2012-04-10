class CreateShareRequests < ActiveRecord::Migration
  def change
    create_table :share_requests do |t|
      t.integer :user_id
      t.integer :squeak_id
      t.string :service      
      t.timestamps
    end
  end
end
