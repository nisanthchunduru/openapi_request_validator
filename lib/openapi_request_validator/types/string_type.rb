class OpenApiRequestValidator
  module Types
    class StringType < Base
      def validate(value)
        raise_incorrect_type_error unless value.is_a?(String)
        if schema["enum"] && !schema["enum"].include?(value)
          raise OpenApiRequestValidator::Errors::UnallowedValue
        end
        if (min_length = schema["minLength"]) && value.length < min_length
          raise OpenApiRequestValidator::Errors::ConstraintNotMet.new("must have a minimum length of #{min_length}")
        end
        return value
      end
    end
  end
end
