module UsersHelper
  def gravatar_for(user, options = { :size => 50 })
    email = user.email
    email.downcase! unless email.nil?
    gravatar_image_tag(user.email.downcase, :alt => user.name,
                                            :class => 'gravatar',
                                            :gravatar => options)
  end
end
