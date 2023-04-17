class OpenApiRequestValidator
  module Types
    class Base
      class << self
        def register_type(type_class)
          @registered_types ||= {}
          @registered_types[type_class.openapi_name] = type_class
        end

        def all
          Types::Base.descendants
        end

        def for_schema(schema)
          type = if schema["type"] == "string" && schema["format"]
            schema["format"]
          elsif schema["anyOf"]
            "anyOf"
          else
            schema["type"]
          end
          all.detect { |type_class| type_class.openapi_name == type }
        end

        def instantiate_for_schema(schema)
          type_class = for_schema(schema)
          raise OpenApiRequestValidator::Errors::UnknownTypeClass unless type_class
          type_class.new(schema)
        end

        def openapi_name
          name.demodulize.underscore.chomp("_type").gsub("_", "-")
        end
      end

      attr_reader :schema

      def initialize(schema)
        @schema = schema
      end

      def openapi_name
        self.class.openapi_name
      end

      def raise_incorrect_type_error
        raise OpenApiRequestValidator::Errors::IncorrectType.new(self.class)
      end
    end
  end
end
