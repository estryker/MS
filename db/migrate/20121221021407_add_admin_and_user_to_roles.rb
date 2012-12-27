class AddAdminAndUserToRoles < ActiveRecord::Migration
  def self.up
    # 10 years for admin, 1 year for auto, 1 week for advertiser, 1 day for user
    Role.create(
                [{:name => 'admin',:max_squeak_duration =>87600},
                 {:name => 'user', :max_squeak_duration => 24},
                 {:name => 'advertiser', :max_squeak_duration => 168},
                 {:name => 'auto',:max_squeak_duration => 8760}]
                )
  end
  
  def self.down
    Role.destroy_all(["name = ? or name = ? or name = ? or name = ?",*%w[admin user advertiser auto]])
  end
end
