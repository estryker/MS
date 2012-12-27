class User < ActiveRecord::Base
  # Note that the foreign key is specified here so that user.squeaks know which 
  # attribute to join on
  has_many :squeaks
  has_many :authorizations
  belongs_to :role # foreign key is  role_id by default
  attr_accessible :name, :email

  after_initialize :init

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :name, :presence => true, 
  :length => {:maximum => 50}
  
  validates :email, :format => {:with => email_regex},
  :uniqueness => { :case_sensitive => false },
  :allow_nil => true
                  
  def add_provider(auth_hash)
    # Check if the provider already exists, so we don't add it twice
    auth = nil
    if auth = authorizations.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      auth.update_credentials!(auth_hash)      
    else
      auth = Authorization.find_or_create(auth_hash, self)
      # Authorization.create :user => self, :provider => auth_hash["provider"], :uid => auth_hash["uid"]
    end
    auth
  end

  def admin?
    self.role_id == Role.where(:name => 'admin').first.id
  end

  def num_squeaks
    (self.squeaks || []).length
  end

  def first_squeak
    (self.squeaks || []).sort {|a,b| a.created_at <=> b.created_at}.first
  end

  def last_squeak
    (self.squeaks || []).sort {|a,b| a.created_at <=> b.created_at}.last
  end

:private
  # by default, make the User have the 'user' role
  def init
    if self.role_id.nil?
      self.role_id = Role.where(:name => 'user').first.id
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

