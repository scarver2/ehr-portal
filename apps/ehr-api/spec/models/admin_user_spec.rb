# spec/models/admin_user_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminUser, type: :model do
  subject(:admin_user) { build(:admin_user) }

  its(:email) { is_expected.to be_present }

  it { is_expected.to be_valid }

  describe 'validations' do
    context 'without email' do
      subject { build(:admin_user, email: nil) }

      it { is_expected.not_to be_valid }
    end

    context 'with duplicate email' do
      before { create(:admin_user, email: 'taken@example.com') }

      subject { build(:admin_user, email: 'taken@example.com') }

      it { is_expected.not_to be_valid }
    end

    context 'without password' do
      subject { build(:admin_user, password: nil, password_confirmation: nil) }

      it { is_expected.not_to be_valid }
    end
  end

  describe '.ransackable_attributes' do
    subject { described_class.ransackable_attributes }

    it { is_expected.to include('email', 'created_at', 'updated_at') }
    it { is_expected.not_to include('encrypted_password') }
  end
end
