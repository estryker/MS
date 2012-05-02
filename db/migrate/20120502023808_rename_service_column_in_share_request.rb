class RenameServiceColumnInShareRequest < ActiveRecord::Migration
  def up
    rename_column :share_requests, :service, :provider
  end

  def down
    rename_column :share_requests, :provider, :service
  end
end
