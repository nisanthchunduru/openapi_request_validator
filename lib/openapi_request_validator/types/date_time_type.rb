class OpenApiRequestValidator
  module Types
    class DateTimeType < Base
      def validate(value)
        coerced_value = if value.is_a?(String)
          begin
            DateTime.parse(value)
          rescue
            raise_incorrect_type_error
          end
        else
          raise_incorrect_type_error
        end
      end
    end
  end
end
