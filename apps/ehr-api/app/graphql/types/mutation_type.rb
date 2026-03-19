# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    description 'The root mutation type.'
    has_no_fields(true)
  end
end
