# apps/ehr-api/app/graphql/types/user_type.rb
# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    description "An authenticated user account."
    implements Types::NodeType

    field :id,         ID,                              null: false
    field :email,      String,                          null: false
    field :role,       String,                          null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :patient,  Types::PatientType,  null: true
    field :provider, Types::ProviderType, null: true
  end
end
