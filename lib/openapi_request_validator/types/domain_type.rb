class OpenApiRequestValidator
  module Types
    class DomainType < StringType
      def validate(value)
        string_value = super(value)
        raise_incorrect_type_error unless Domain.valid?(string_value)
        return string_value
      end
    end
  end
end
