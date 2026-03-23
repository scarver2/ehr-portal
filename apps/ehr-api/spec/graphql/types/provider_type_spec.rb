# spec/graphql/types/provider_type_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::ProviderType do
  subject(:fields) { described_class.fields }

  it {
    expect(subject).to include('id', 'firstName', 'lastName', 'fullName', 'npi', 'specialty', 'clinicName', 'createdAt',
                               'updatedAt')
  }

  describe 'field nullability' do
    it 'marks id as non-null' do
      expect(fields['id'].type.to_type_signature).to include('!')
    end

    it 'marks createdAt as non-null' do
      expect(fields['createdAt'].type.to_type_signature).to include('!')
    end

    it 'marks updatedAt as non-null' do
      expect(fields['updatedAt'].type.to_type_signature).to include('!')
    end
  end

  describe '#full_name resolver' do
    subject(:result) do
      EhrApiSchema.execute(
        "{ provider(id: \"#{provider.id}\") { fullName } }",
        context: {}
      )
    end

    let(:provider) { create(:provider, first_name: 'Jane', last_name: 'Doe') }

    it 'returns no errors' do
      expect(result['errors']).to be_nil
    end

    it 'concatenates first and last name' do
      expect(result.dig('data', 'provider', 'fullName')).to eq('Jane Doe')
    end
  end

  describe '#location resolver' do
    context 'when the provider has city and state' do
      subject(:result) do
        EhrApiSchema.execute(
          "{ provider(id: \"#{provider.id}\") { location } }",
          context: {}
        )
      end

      let(:provider) { create(:provider, city: 'Boston', state: 'MA') }

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end

      it 'returns city and state joined with a comma' do
        expect(result.dig('data', 'provider', 'location')).to eq('Boston, MA')
      end
    end

    context 'when the provider has no city or state' do
      subject(:result) do
        EhrApiSchema.execute(
          "{ provider(id: \"#{provider.id}\") { location } }",
          context: {}
        )
      end

      let(:provider) { create(:provider, city: nil, state: nil) }

      it 'returns no errors' do
        expect(result['errors']).to be_nil
      end

      it 'returns an empty string' do
        expect(result.dig('data', 'provider', 'location')).to eq('')
      end
    end
  end
end
