class OpenApiRequestValidator
  module Errors
    class RequestJsonIsInvalid < StandardError; end

    class ValidationError < StandardError; end

    class UnknownTypeClass < ValidationError; end

    class IncorrectType < ValidationError
      attr_reader :expected_types

      def initialize(expected_type_or_expected_types)
        @expected_types = Array(expected_type_or_expected_types)
      end
    end

    class ConstraintNotMet < ValidationError
      alias_method :description, :message
    end

    class UnallowedValue < ValidationError; end

    class ObjectRequiredPropertyMissing < ValidationError
      attr_reader :property_path

      def initialize(property_path)
        @property_path = property_path
      end
    end

    class ObjectPropertyHasIncorrectType < ValidationError
      attr_reader :property_path,
                  :expected_types

      def initialize(property_path, expected_types)
        @property_path, @expected_types = property_path, Array(expected_types)
      end
    end

    class ObjectPropertyConstraintNotMet < ValidationError
      attr_reader :property_path,
                  :description

      def initialize(property_path, description)
        @property_path, @description = property_path, description
      end
    end

    class ApiRequestValidationFailed < StandardError; end
  end
end
