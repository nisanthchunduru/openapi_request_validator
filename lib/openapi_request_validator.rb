class OpenApiRequestValidator
  class << self
    def open_api_spec_path
      return @open_api_spec_path if instance_variable_defined?(@open_api_spec_path)
      Rails.root.join("openapi.yml").to_s
    end
  end
end
