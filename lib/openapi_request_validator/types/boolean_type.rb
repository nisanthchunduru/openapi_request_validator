class OpenApiRequestValidator
  module Types
    class BooleanType < Base
      def validate(value)
        coerced_value = if value.is_a?(String) && value.boolean?
          value == "true" ? true : false
        elsif [true, false].include?(value)
          value
        else
          raise_incorrect_type_error
        end
      end
    end
  end
end
