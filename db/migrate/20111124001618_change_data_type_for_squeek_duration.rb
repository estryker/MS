class ChangeDataTypeForSqueekDuration < ActiveRecord::Migration
  def up
    change_table :squeeks do |t|
      t.change :duration, :float
    end
  end

  def down
    change_table :squeeks do |t|
      t.change :duration, :integer
    end
  end
end
