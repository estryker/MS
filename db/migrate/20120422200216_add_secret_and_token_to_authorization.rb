class AddSecretAndTokenToAuthorization < ActiveRecord::Migration
  def self.up
    add_column :authorizations, :secret, :string
    add_column :authorizations, :token, :string
  end

  def self.down
    remove_column :secret
    remove_column :token
  end
end
