class OpenApiRequestValidator
  module Types
    class AnyOfType < Base
      class << self
        def openapi_name
          "anyOf"
        end
      end

      def validate(value)
        validation_results = schema["anyOf"].map do |type_schema|
          type = Base.instantiate_for_schema(type_schema)
          begin
            type.validate(value)
          rescue OpenApiRequestValidator::ValidationError => e
            e
          end
        end

        validated_value = validation_results.detect { |validation_result| !validation_result.is_a?(OpenApiRequestValidator::Error) }
        return validated_value unless validated_value.nil?

        if validation_results.all? { |e| [OpenApiRequestValidator::Errors::IncorrectType].include?(e.class) }
          raise OpenApiRequestValidator::Errors::IncorrectType.new(allowed_type_classes)
        else
          raise validation_results.detect { |e| ![OpenApiRequestValidator::Errors::IncorrectType].include?(e.class) }
        end
      end

      private

      def allowed_type_classes
        schema["anyOf"].map { |type_schema| Base.for_schema(type_schema) }
      end
    end
  end
end
