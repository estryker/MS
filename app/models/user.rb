class User < ActiveRecord::Base
  # Note that the foreign key is specified here so that user.squeaks know which 
  # attribute to join on
  has_many :squeaks
  has_many :authorizations
  attr_accessible :name, :email

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :name, :presence => true, 
  :length => {:maximum => 50}
  
  validates :email, :format => {:with => email_regex},
  :uniqueness => { :case_sensitive => false },
  :allow_nil => true
                  
  def add_provider(auth_hash)
    # Check if the provider already exists, so we don't add it twice
    unless authorizations.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      Authorization.find_or_create(auth_hash)
      # Authorization.create :user => self, :provider => auth_hash["provider"], :uid => auth_hash["uid"]
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#

