class OpenApiRequestValidator
  module Types
    class EmailAddressType < StringType
      def validate(value)
        string_value = super(value)
        raise_incorrect_type_error unless EmailAddress.valid?(string_value)
        return string_value
      end
    end
  end
end
