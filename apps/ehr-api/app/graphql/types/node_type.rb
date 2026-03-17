# frozen_string_literal: true

module Types
  module NodeType
    include Types::BaseInterface

    description 'An object with a globally unique ID.'
    # Add the `id` field
    include GraphQL::Types::Relay::NodeBehaviors
  end
end
