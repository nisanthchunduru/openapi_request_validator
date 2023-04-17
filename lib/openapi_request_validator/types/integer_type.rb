class OpenApiRequestValidator
  module Types
    class IntegerType < Base
      def validate(value)
        coerced_value = if value.is_a?(String) && value.integer?
          value.to_i
        elsif value.is_a?(Integer)
          value
        else
          raise_incorrect_type_error
        end

        minimum_value = schema["minimum"]
        if minimum_value && coerced_value < minimum_value
          raise OpenApiRequestValidator::Errors::ConstraintNotMet.new("must be greater than or equal to #{minimum_value}")
        end

        maximum_value = schema["maximum"]
        if maximum_value && coerced_value > maximum_value
          raise OpenApiRequestValidator::Errors::ConstraintNotMet.new("must be less than or equal to #{maximum_value}")
        end

        return coerced_value
      end
    end
  end
end
