# spec/models/provider_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Provider, type: :model do
  subject(:provider) { build(:provider) }

  its(:first_name)  { is_expected.to be_present }
  its(:last_name)   { is_expected.to be_present }
  its(:npi)         { is_expected.to match(/\A\d{10}\z/) }
  its(:specialty)   { is_expected.to be_present }
  its(:clinic_name) { is_expected.to be_present }

  describe '.ransackable_attributes' do
    subject { described_class.ransackable_attributes }

    it { is_expected.to include('first_name', 'last_name', 'npi', 'specialty', 'clinic_name') }
    it { is_expected.not_to include('encrypted_password') }
  end
end
