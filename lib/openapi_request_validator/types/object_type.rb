class OpenApiRequestValidator
  module Types
    class ObjectType < Base
      def validate(value)
        unless value.is_a?(Hash)
          raise_incorrect_type_error
        end

        required_keys = schema["required"].to_a
        if required_keys
          missing_keys = required_keys - value.keys
          unless missing_keys.empty?
            raise OpenApiRequestValidator::Errors::ObjectRequiredPropertyMissing.new(missing_keys.first)
          end
        end

        validated_value = {}
        schema["properties"].each do |param_name, param_schema|
          if !value.has_key?(param_name)
            if (param_default_value = param_schema["default"])
              validated_value[param_name] = param_default_value
            end
            next
          end

          param_value = value[param_name]
          type = Base.instantiate_for_schema(param_schema)
          begin
            validated_value[param_name] = type.validate(param_value)
          rescue OpenApiRequestValidator::IncorrectType => e
            raise OpenApiRequestValidator::Errors::ObjectPropertyHasIncorrectType.new(param_name, e.expected_types)
          rescue OpenApiRequestValidator::Errors::ObjectPropertyHasIncorrectType => e
            raise OpenApiRequestValidator::Errors::ObjectPropertyHasIncorrectType.new("#{param_name}.#{e.property_path}", e.expected_types)
          rescue OpenApiRequestValidator::Errors::ObjectRequiredPropertyMissing => e
            raise OpenApiRequestValidator::Errors::ObjectRequiredPropertyMissing.new("#{param_name}.#{e.property_path}")
          rescue OpenApiRequestValidator::Errors::ObjectPropertyConstraintNotMet => e
            raise OpenApiRequestValidator::Errors::ObjectPropertyConstraintNotMet.new("#{param_name}.#{e.property_path}", e.description)
          end
        end

        return validated_value
      end
    end
  end
end
