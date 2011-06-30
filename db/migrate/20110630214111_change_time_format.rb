class ChangeTimeFormat < ActiveRecord::Migration
  def self.up
    change_column :squeeks, :time_utc, :datetime
    change_column :squeeks, :expires, :datetime
  end

  def self.down
    # this is bad, but I don't care. data will be lost, but heroku 
    # won't drop tables. 
    change_column :squeeks, :time_utc, :time
    change_column :squeeks, :expires, :time
  end
end
