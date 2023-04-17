# openapi_request_validator

`open_api_request_validator` validates API requests sent to your REST API using your API's OpenAPI specification

`open_api_request_validator` is a great alternative to Rails' strong parameters

## Install

Add the gem to your Rails application's Gemfile

```ruby
gem "openapi_request_validator", git: "https://github.com/nisanthchunduru/openapi_request_validator", branch: "main"
```

And install it

```bash
bundle install
```

Include the `OpenApiRequestValidator::ApiRequestValidation` module in your `ApplicationController`

```ruby
# In controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include OpenApiRequestValidator::ApiRequestValidation
end
```

Add an OpenAPI specification to your project (but you presumably have one already :))

```
# openapi.yml

openapi: 3.0.3

info:
  title: Acme REST API
  version: 0.0.1

servers:
  - url: https://api.acme.com
    description: API Base URL

paths:
  /conversations.json:
    post: Create conversation
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              title:
                type: string
                required: true
              content:
                type: object
                properties:
                  text:
                    type: string
                    required: true
```

`openapi_request_validator` assumes that your Rails root directory contains your project's OpenAPI specification file and that the file is named `openapi.yml`. In case your OpenAPI specification file lies elsewhere, share its path with `openapi_request_validator` in an initializer file

```ruby
# In config/initializers/openapi_request_validator.rb

OpenApiRequestValidator.open_api_spec_path = Rails.root.join("openapi_spec.yml)
```

Start rails

```
bundle exec rails s
```

and send an API request to an API endpoint

```
curl -X POST https://api.lvh.me:3000/conversations -H "Content-Type: application/json" -D '{ "conversation": { "content": { "text": "Hey, do you offer discounts for non-profits?" } } }'
```

## Todos

- Port rspecs here
- Add more usage examples
- Publish to rubygems.org
