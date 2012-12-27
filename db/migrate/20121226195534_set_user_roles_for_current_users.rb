class SetUserRolesForCurrentUsers < ActiveRecord::Migration
  def up
    role_id = Role.where(:name => 'user')
    User.all {|u| u.role_id = role_id ; u.save}
  end

  def down
    # For now, don't do anything b/c we don't know which ones we changed
  end
end
