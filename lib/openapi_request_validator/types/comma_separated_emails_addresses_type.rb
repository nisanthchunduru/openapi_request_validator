class OpenApiRequestValidator
  module Types
    class CommaSeparatedEmailAddressesType < StringType
      def validate(value)
        string_value = super(value)
        begin
          return string_value if Mail::AddressList.new(string_value).addresses.map(&:address).all? { |email_address| EmailAddress.valid?(email_address) }
          raise_incorrect_type_error
        rescue => e
          raise_incorrect_type_error
        end
      end
    end
  end
end
