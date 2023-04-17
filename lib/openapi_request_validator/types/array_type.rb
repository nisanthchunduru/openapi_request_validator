class OpenApiRequestValidator
  module Types
    class ArrayType < Base
      def validate(value)
        unless value.is_a?(Array)
          raise_incorrect_type_error
        end

        item_type = Base.instantiate_for_schema(schema["items"])
        value.map.with_index do |item_value, index|
          begin
            item_type.validate(item_value)
          rescue OpenApiRequestValidator::Errors::IncorrectType => e
            raise OpenApiRequestValidator::Errors::ObjectPropertyHasIncorrectType.new("[#{index}]", item_type)
          rescue OpenApiRequestValidator::Errors::ObjectPropertyConstraintNotMet => e
            raise OpenApiRequestValidator::Errors::ObjectPropertyConstraintNotMet.new("[#{index}]", e.description)
          end
        end
      end
    end
  end
end
