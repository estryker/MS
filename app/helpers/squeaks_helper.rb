module SqueaksHelper
  class SqueakDurationValidator < ActiveModel::EachValidator
    
    def validate_each(squeak_record, attribute, value)
      if value > 0
        if squeak_record.user_id 
          user = User.find(squeak_record.user_id) 
          if user && user.role_id
            role = Role.find(user.role_id) 
            unless role && value <= (max_duration = role.max_squeak_duration || 24)
              squeak_record.errors(attribute, "duration must be less than #{max_duration} according to current role")
            end
          else
            unless value <= 24
              squeak_record.errors(attribute, "duration must be less than 24 hours by default")
            end
          end
        else
          unless value <= 24
            squeak_record.errors(attribute, "duration must be less than 24 for squeaks with no user id")
          end
        end
      else
        squeak_record.errors(attribute, "duration must be greater than 0")
      end
    end
  end
end
