# frozen_string_literal: true

# This file is auto-loaded by SimpleCov.start in spec/spec_helper.rb.
# Use SimpleCov.configure (not SimpleCov.start) here to avoid a double-start.
SimpleCov.configure do
  enable_coverage_for_eval
  minimum_coverage 50

  # Exclude graphql-ruby generated boilerplate that ships with every new schema.
  # These Base* stubs, the schema wiring, and the generated controller contain no
  # app-specific logic and will never hit 100% without meaningless tests.
  add_filter %r{/graphql/(types|mutations|resolvers)/base_}
  add_filter '/graphql/ehr_api_schema.rb'
  add_filter '/controllers/graphql_controller.rb'

  add_group 'GraphQL', 'app/graphql'
  add_group 'Admin',   'app/admin'
end
