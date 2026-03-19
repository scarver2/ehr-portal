# spec/models/user_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  its(:email) { is_expected.to be_present }
  its(:role)  { is_expected.to eq('patient') }

  it { is_expected.to be_valid }

  describe "associations" do
    it "has one patient, destroyed when the user is destroyed" do
      u = create(:user, :patient)
      create(:patient, user: u)
      expect { u.destroy }.to change(Patient, :count).by(-1)
    end

    it "has one provider, whose user_id is nullified when the user is destroyed" do
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

  describe '.provider_accounts' do
    let!(:provider_user) { create(:user, :provider) }
    let!(:admin_user)    { create(:user, :admin) }
    let!(:patient_user)  { create(:user, :patient) }

    it 'includes only provider-role users' do
      expect(User.provider_accounts).to include(provider_user)
      expect(User.provider_accounts).not_to include(admin_user, patient_user)
    end

    it 'orders results by email' do
      second = create(:user, :provider, email: 'zzz@example.com')
      first  = create(:user, :provider, email: 'aaa@example.com')
      emails = User.provider_accounts.map(&:email)
      expect(emails.index(first.email)).to be < emails.index(second.email)
    end
  end
end
