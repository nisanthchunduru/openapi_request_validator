module ApiRequestValidation
  extend ActiveSupport::Concern

  included do
    before_action :validate_query_params,
                  :validate_request_body,
                  if: Proc.new { request.format.json? }

    rescue_from OpenApiRequestValidator::Errors::ApiRequestValidationFailed do |exception|
      respond_with_validation_error_message(exception.message)
    end

    attr_reader :validated_query_params,
                :validated_body_params,
                :validated_params
  end

  def validate_query_params
    @validated_query_params = {}

    parameters_spec = current_request.openapi_request_parameters_spec
    return unless parameters_spec

    parameters_spec.each do |param_spec|
      next unless param_spec["in"] == "query"

      param_name = param_spec["name"]

      if param_spec["required"] && !query_params.has_key?(param_name)
        raise OpenApiRequestValidator::Errors::ApiRequestValidationFailed.new("Query param '#{param_name}' is required")
      end

      param_schema = param_spec["schema"]

      param_default_value = param_schema["default"]
      if !query_params.has_key?(param_name)
        if param_default_value
          @validated_query_params[param_name] = param_default_value
        end

        next
      end

      type = OpenApiRequestValidator::Types::Base.instantiate_for_schema(param_schema)
      param_value = query_params[param_name]
      begin
        validated_param_value = type.validate(param_value)
        @validated_query_params[param_name] = validated_param_value
      rescue OpenApiRequestValidator::Errors::ValidationError => e
        api_error_message = if e.is_a?(OpenApiRequestValidator::Errors::IncorrectType)
          "Query param '#{param_name}' must be a #{expected_types_sentence(e.expected_types)}"
        elsif e.is_a?(OpenApiRequestValidator::Errors::ConstraintNotMet)
          "Query param '#{param_name}' #{e.description}"
        elsif e.is_a?(OpenApiRequestValidator::Errors::UnallowedValue)
          "Query param '#{param_name}' doesn't have a valid value"
        else
          "Query params validation failed"
        end

        raise OpenApiRequestValidator::Errors::ApiRequestValidationFailed.new(api_error_message)
      end
    end
  end

  def validate_request_body
    @validated_body_params = {}
    request_body_schema = current_request.openapi_request_body_schema
    return unless request_body_schema

    type = OpenApiRequestValidator::Types::Base.instantiate_for_schema(request_body_schema)
    begin
      @validated_body_params = type.validate(body_params)
    rescue OpenApiRequestValidator::ValidationError => e
      api_error_message = if e.is_a?(OpenApiRequestValidator::Errors::ObjectRequiredPropertyMissing)
        property_path = e.property_path
        "Body param '#{property_path}' is required"
      elsif e.is_a?(OpenApiRequestValidator::Errors::ObjectPropertyHasIncorrectType)
        property_path = e.property_path
        "Body param '#{property_path}' must be a #{expected_types_sentence(e.expected_types)}"
      elsif e.is_a?(OpenApiRequestValidator::Errors::ObjectPropertyConstraintNotMet)
        property_path = e.property_path
        description = e.description
        "Body param '#{property_path}' #{e.description}"
      else
        "Body params validation failed"
      end

      raise OpenApiRequestValidator::Errors::ApiRequestValidationFailed.new(api_error_message)
    end
  end

  def openapi_path_spec
    openapi_spec.paths[openapi_path]
  end

  def openapi_request_body_schema
    openapi_request_spec
      .try(:[], "requestBody")
      .try(:[], "content")
      .try(:[], "application/json")
      .try(:[], "schema")
  end

  def openapi_request_spec
    http_method = request.method.downcase
    openapi_path_spec.try(http_method)
  end

  def openapi_spec
    return @openapi_spec if Rails.env.production? && instance_variable_defined?(:@openapi_spec)
    @openapi_spec = Openapi3Parser.load_file(openapi_spec_path)
  end

  def respond_with_validation_error_message(error_message)
    response_json = { error: error_message }.to_json
    respond_to { |format|
      format.json { render json: response_json, status: 400 }
    }
  end

  def path_params
    @path_params ||= request.path_parameters.stringify_keys
  end

  def query_params
    request.query_parameters
  end

  def body_params
    @body_params ||= JSON.parse(request_body)
  rescue JSON::ParserError
    raise OpenApiRequestValidator::Errors::RequestJsonIsInvalid
  end

  def request_body
    @request_body ||= request.raw_post
  end

  private

  def expected_types_sentence(expected_types)
    expected_types.map(&:openapi_name).to_sentence(two_words_connector: " or ", last_word_connector: " or ")
  end
end

