# spec/graphql/types/query_type_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::QueryType do
  subject(:fields) { described_class.fields }

  it { is_expected.to include('providers', 'provider') }

  describe 'providers field' do
    subject(:field) { described_class.fields['providers'] }

    its(:name) { is_expected.to eq('providers') }

    it 'returns a list type' do
      expect(field.type.list?).to be true
    end
  end

  describe 'provider field' do
    subject(:field) { described_class.fields['provider'] }

    its(:name) { is_expected.to eq('provider') }

    it 'accepts an id argument' do
      expect(field.arguments.keys).to include('id')
    end
  end
end
