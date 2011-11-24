class ChangeDataTypeForSqueakDuration < ActiveRecord::Migration
  def up
    change_table :squeaks do |t|
      t.change :duration, :float
    end
  end

  def down
    change_table :squeaks do |t|
      t.change :duration, :integer
    end
  end
end
