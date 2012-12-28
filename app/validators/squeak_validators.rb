# **Not in use right now. 
class SqueakDurationValidator < ActiveModel::EachValidator
  def validate_each(squeak_record, attribute, value)
    if value > 0
      if squeak_record.user_id 
        user = User.find(squeak_record.user_id) 
        if user && user.role_id
          role = Role.find(user.role_id) 
          unless role && value <= (max_duration = role.max_squeak_duration || 24)
            squeak_record.errors.add attribute , "duration must be less than #{max_duration} according to current role"
          end
        else
          unless value <= 24
            squeak_record.errors.add attribute, "duration must be less than 24 hours by default"
          end
        end
      else 
        unless value <= 24
          squeak_record.errors.add attribute, "duration must be less than 24 for squeaks with no user id"
        end
      end
    else
      squeak_record.errors.add attribute, "duration must be greater than 0"
    end
  end
end
class SqueakExpirationValidator < ActiveModel::EachValidator
  def validate_each(squeak_record, attribute, value)
    created_at = squeak_record.created_at || 0.hours.ago
    squeak_duration = (squeak_record.expires - created_at).to_f / 1.hour
    if squeak_duration > 0
      if squeak_record.user_id 
        user = User.find(squeak_record.user_id) 
        if user && user.role_id
          role = Role.find(user.role_id) 
          
          unless role && squeak_duration <= (max_duration = role.max_squeak_duration || 24)
            squeak_record.errors.add attribute , "duration must be less than #{max_duration} according to current role"
          end
        else
          unless squeak_duration <= 24
            squeak_record.errors.add attribute, "duration must be less than 24 hours by default"
          end
        end
      else 
        unless squeak_duration <= 24
          squeak_record.errors.add attribute, "duration must be less than 24 for squeaks with no user id"
        end
      end
    else
      squeak_record.errors.add attribute, "duration must be greater than 0"
    end
  end
end

# This was kinda clever, but really we should only validate expiration, not the duration and expiration. 
# This attempts to link the two so editing the rules only occurs in one place. 
class SqueakExpirationValidator2 < ActiveModel::EachValidator
  def initialize(options)
    # This is a bit of a hack, but I want the logic of the expiration validator
    # to be completely tied to the duration validator.  I needed to copy out the 
    # @attributes, just like the parent class so that I could use them twice. They
    # get deleted in the parent constructor, and I need them in the call to 
    # super and SqueakDurationValidator.new
    @attributes = Array.wrap(options.delete(:attributes))
    raise ":attributes cannot be blank" if @attributes.empty?
    @durationValidator = SqueakDurationValidator.new(options.merge(:attributes => @attributes))
    options.merge!(:attributes => @attributes)
    super
  end

  def validate_each(squeak_record, attribute, value)
    duration = (squeak_record.expires - squeak_record.created_at).to_f / 1.hour
    @durationValidator.validate_each(squeak_record,attribute,duration)
  end
end
