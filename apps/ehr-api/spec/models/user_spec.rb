# spec/models/user_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  its(:email) { is_expected.to be_present }
  its(:role)  { is_expected.to eq('patient') }

  it { is_expected.to be_valid }

  describe 'validations' do
    context 'without email' do
      subject { build(:user, email: nil) }

      it { is_expected.not_to be_valid }
    end

    context 'with duplicate email' do
      before { create(:user, email: 'taken@example.com') }

      subject { build(:user, email: 'taken@example.com') }

      it { is_expected.not_to be_valid }
    end

    context 'without password' do
      subject { build(:user, password: nil, password_confirmation: nil) }

      it { is_expected.not_to be_valid }
    end

    context 'without role' do
      subject { build(:user, role: nil) }

      it { is_expected.not_to be_valid }
    end

    context 'with an invalid role' do
      subject { build(:user) }

      it 'is invalid with an unknown role value' do
        subject.write_attribute(:role, 'superuser')
        expect(subject).not_to be_valid
      end
    end
  end

  describe 'role predicates' do
    it { expect(build(:user, :admin)).to    be_admin }
    it { expect(build(:user, :provider)).to be_provider }
    it { expect(build(:user, :staff)).to    be_staff }
    it { expect(build(:user, :patient)).to  be_patient }
  end
end
