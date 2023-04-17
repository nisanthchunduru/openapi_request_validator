$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "open_api_request_validator/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name          = "open_api_request_validator"
  s.version       = Gmail::VERSION
  s.authors       = ["Nisanth Chunduru"]
  s.email         = ["nisanth074@gmail.com"]
  s.homepage      = "https://github.com/nisanth074/gmail"
  s.summary       = "Validate your REST API's API requests using the API's OpenAPI specification"
  s.description   = "Validate your REST API's API requests using the API's OpenAPI specification"

  s.files = Dir["{lib}/**/*", "README.md"]

  s.add_dependency "openapi3_parser"
  s.add_dependency "email_address"
  s.add_development_dependency "pry"
  s.add_development_dependency "rspec", '~> 3.9'
end
