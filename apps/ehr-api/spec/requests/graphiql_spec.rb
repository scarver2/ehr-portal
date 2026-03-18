# spec/requests/graphiql_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphiQL route', type: :routing do
  it 'is not routable outside the development environment' do
    expect(get: '/graphiql').not_to be_routable
  end
end
