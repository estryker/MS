class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
      t.float :max_squeak_duration
      t.timestamps
    end
  end
end
