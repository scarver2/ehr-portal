# spec/models/user_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  its(:email) { is_expected.to be_present }

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
  end
end
