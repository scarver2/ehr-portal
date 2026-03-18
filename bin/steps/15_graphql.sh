#!/usr/bin/env bash
# bin/steps/15_graphql.sh

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

check "bundle"

info "Adding GraphQL..."
bundle add graphql
bundle add graphql-rails --group development
bin/rails generate graphql:install

# TODO: add GraphQL unit and request specs

info "Adding GraphQL RBS shim and type signatures..."

cat << 'EOF' > sig/shims/graphql.rbs
# sig/shims/graphql.rbs
# Minimal stubs for graphql-ruby classes used in app/graphql/.
# Remove once graphql-ruby ships official RBS definitions.

module GraphQL
  class Dataloader
  end

  class RequiredImplementationMissingError < ::StandardError
  end

  class InvalidNullError < ::StandardError
  end

  module Types
    module Relay
      module NodeBehaviors
      end

      module ConnectionBehaviors
      end

      module EdgeBehaviors
      end
    end

    class ISO8601DateTime
    end
  end

  class Schema
    def self.mutation: (untyped) -> void
    def self.query: (untyped) -> void
    def self.use: (untyped, **untyped) -> void
    def self.max_query_string_tokens: (::Integer) -> void
    def self.validate_max_errors: (::Integer) -> void
    def self.execute: (
      ?::String? query,
      ?variables: untyped,
      ?context: ::Hash[::Symbol, untyped],
      ?operation_name: ::String?
    ) -> untyped

    def self.type_error: (untyped err, untyped context) -> untyped
    def self.resolve_type: (untyped abstract_type, untyped obj, untyped ctx) -> untyped
    def self.id_from_object: (untyped object, untyped type_definition, untyped query_ctx) -> ::String
    def self.object_from_id: (::String global_id, untyped query_ctx) -> untyped

    class Object
      def self.field_class: (untyped klass) -> void
      def self.edge_type_class: (untyped klass) -> void
      def self.connection_type_class: (untyped klass) -> void
      def self.implements: (*untyped interfaces) -> void
      def self.field: (::Symbol | ::String name, *untyped, **untyped) ?{ () -> void } -> untyped
      def self.description: (?::String text) -> ::String?

      def object: () -> untyped
      def context: () -> untyped
    end

    class Field
      def self.argument_class: (untyped klass) -> void
    end

    class Argument
    end

    module Interface
      def self.included: (untyped base) -> void
      def self.field_class: (untyped klass) -> void
      def self.edge_type_class: (untyped klass) -> void
      def self.connection_type_class: (untyped klass) -> void
      def self.implements: (*untyped interfaces) -> void
      def self.field: (::Symbol | ::String name, *untyped, **untyped) ?{ () -> void } -> untyped
      def self.description: (?::String text) -> ::String?
      def self.include: (untyped mod) -> void
    end

    class RelayClassicMutation
      def self.argument_class: (untyped klass) -> void
      def self.field_class: (untyped klass) -> void
      def self.input_object_class: (untyped klass) -> void
      def self.object_class: (untyped klass) -> void
    end

    class Resolver
    end

    class Union
      def self.edge_type_class: (untyped klass) -> void
      def self.connection_type_class: (untyped klass) -> void
    end

    class Enum
    end

    class Scalar
    end

    class InputObject
      def self.argument_class: (untyped klass) -> void
    end
  end
end
EOF

cat << 'EOF' > sig/app/controllers/graphql_controller.rbs
# sig/app/controllers/graphql_controller.rbs

class GraphqlController < ApplicationController
  def execute: () -> void

  private

  def prepare_variables: (
    ::String | ::Hash[untyped, untyped] | ActionController::Parameters | nil
  ) -> ::Hash[untyped, untyped]

  def handle_error_in_development: (::Exception e) -> void
end
EOF

cat << 'EOF' > sig/app/graphql/ehr_api_schema.rbs
# sig/app/graphql/ehr_api_schema.rbs

class EhrApiSchema < GraphQL::Schema
  def self.type_error: (untyped err, untyped context) -> untyped
  def self.resolve_type: (untyped abstract_type, untyped obj, untyped ctx) -> untyped
  def self.id_from_object: (untyped object, untyped type_definition, untyped query_ctx) -> ::String
  def self.object_from_id: (::String global_id, untyped query_ctx) -> untyped
end
EOF

cat << 'EOF' > sig/app/graphql/types/base_object.rbs
# sig/app/graphql/types/base_object.rbs

module Types
  class BaseObject < GraphQL::Schema::Object
  end
end
EOF

cat << 'EOF' > sig/app/graphql/types/base_argument.rbs
# sig/app/graphql/types/base_argument.rbs

module Types
  class BaseArgument < GraphQL::Schema::Argument
  end
end
EOF

cat << 'EOF' > sig/app/graphql/types/base_field.rbs
# sig/app/graphql/types/base_field.rbs

module Types
  class BaseField < GraphQL::Schema::Field
  end
end
EOF

cat << 'EOF' > sig/app/graphql/types/base_enum.rbs
# sig/app/graphql/types/base_enum.rbs

module Types
  class BaseEnum < GraphQL::Schema::Enum
  end
end
EOF

cat << 'EOF' > sig/app/graphql/types/base_scalar.rbs
# sig/app/graphql/types/base_scalar.rbs

module Types
  class BaseScalar < GraphQL::Schema::Scalar
  end
end
EOF

cat << 'EOF' > sig/app/graphql/types/base_union.rbs
# sig/app/graphql/types/base_union.rbs

module Types
  class BaseUnion < GraphQL::Schema::Union
  end
end
EOF

cat << 'EOF' > sig/app/graphql/types/base_input_object.rbs
# sig/app/graphql/types/base_input_object.rbs

module Types
  class BaseInputObject < GraphQL::Schema::InputObject
  end
end
EOF

cat << 'EOF' > sig/app/graphql/types/base_interface.rbs
# sig/app/graphql/types/base_interface.rbs

module Types
  module BaseInterface
    include GraphQL::Schema::Interface
  end
end
EOF

cat << 'EOF' > sig/app/graphql/types/base_connection.rbs
# sig/app/graphql/types/base_connection.rbs

module Types
  class BaseConnection < Types::BaseObject
    include GraphQL::Types::Relay::ConnectionBehaviors
  end
end
EOF

cat << 'EOF' > sig/app/graphql/types/base_edge.rbs
# sig/app/graphql/types/base_edge.rbs

module Types
  class BaseEdge < Types::BaseObject
    include GraphQL::Types::Relay::EdgeBehaviors
  end
end
EOF

cat << 'EOF' > sig/app/graphql/types/node_type.rbs
# sig/app/graphql/types/node_type.rbs

module Types
  module NodeType
    include Types::BaseInterface
    include GraphQL::Types::Relay::NodeBehaviors
  end
end
EOF

cat << 'EOF' > sig/app/graphql/types/mutation_type.rbs
# sig/app/graphql/types/mutation_type.rbs

module Types
  class MutationType < Types::BaseObject
  end
end
EOF

cat << 'EOF' > sig/app/graphql/types/query_type.rbs
# sig/app/graphql/types/query_type.rbs
# Add typed query method signatures as resolvers are implemented.

module Types
  class QueryType < Types::BaseObject
    def node: (id: ::String) -> untyped
    def nodes: (ids: ::Array[::String]) -> ::Array[untyped]
  end
end
EOF

cat << 'EOF' > sig/app/graphql/mutations/base_mutation.rbs
# sig/app/graphql/mutations/base_mutation.rbs

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
  end
end
EOF

cat << 'EOF' > sig/app/graphql/resolvers/base_resolver.rbs
# sig/app/graphql/resolvers/base_resolver.rbs

module Resolvers
  class BaseResolver < GraphQL::Schema::Resolver
  end
end
EOF
