# spec/models/user_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  subject(:user) { create(:user) }

  its(:email) { is_expected.to be_present }

  it { is_expected.to be_valid }

  describe 'associations' do
    it 'has one account for password management' do
      expect(user.account).to be_a(Account)
    end

    it 'has one patient, destroyed when the user is destroyed' do
      u = create(:user, :patient)
      create(:patient, user: u)
      expect { u.destroy }.to change(Patient, :count).by(-1)
    end

    it 'has one provider, whose user_id is nullified when the user is destroyed' do
      u = create(:user, :provider)
      p = create(:provider, user: u)
      u.destroy
      expect(p.reload.user_id).to be_nil
    end
  end

  describe 'validations' do
    context 'without email' do
      subject { build(:user, email: nil) }

      it { is_expected.not_to be_valid }
    end

    context 'with duplicate email' do
      subject { build(:user, email: 'taken@example.com') }

      before { create(:user, email: 'taken@example.com') }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'role management via Rolify' do
    it 'is assigned patient role by default' do
      expect(user.has_role?(:patient)).to be(true)
    end

    it 'can have multiple roles' do
      user.add_role(:provider)
      expect(user.has_role?(:patient)).to be(true)
      expect(user.has_role?(:provider)).to be(true)
    end

    it 'can have roles removed' do
      user.add_role(:provider)
      user.remove_role(:patient)
      expect(user.has_role?(:patient)).to be(false)
      expect(user.has_role?(:provider)).to be(true)
    end
  end

  describe '.provider_accounts' do
    let!(:provider_user) { create(:user, :provider) }
    let!(:patient_user)  { create(:user, :patient) }

    it 'includes only provider-role users' do
      expect(described_class.provider_accounts).to include(provider_user)
      expect(described_class.provider_accounts).not_to include(patient_user)
    end

    it 'orders results by email' do
      second = create(:user, :provider, email: 'zzz@example.com')
      first  = create(:user, :provider, email: 'aaa@example.com')
      emails = described_class.provider_accounts.map(&:email)
      expect(emails.index(first.email)).to be < emails.index(second.email)
    end
  end
end
