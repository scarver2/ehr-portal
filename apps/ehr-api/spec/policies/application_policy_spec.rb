# spec/policies/application_policy_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { double("record") }

  context "when the user is a provider" do
    let(:user) { build(:user, :provider) }

    it { is_expected.not_to be_index }
    it { is_expected.not_to be_show }
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_new }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_edit }
    it { is_expected.not_to be_destroy }
  end

  context "when the user is staff" do
    let(:user) { build(:user, :staff) }

    it { is_expected.not_to be_index }
    it { is_expected.not_to be_show }
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_destroy }
  end

  context "when the user is a patient" do
    let(:user) { build(:user, :patient) }

    it { is_expected.not_to be_index }
    it { is_expected.not_to be_show }
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_destroy }
  end

  describe "#new? delegates to #create?" do
    let(:user) { build(:user, :provider) }

    it "returns the same value as create?" do
      expect(policy.new?).to eq(policy.create?)
    end
  end

  describe "#edit? delegates to #update?" do
    let(:user) { build(:user, :provider) }

    it "returns the same value as update?" do
      expect(policy.edit?).to eq(policy.update?)
    end
  end

  describe ApplicationPolicy::Scope do
    subject(:scope) { described_class.new(user, relation) }

    let(:user)     { build(:user, :provider) }
    let(:relation) { double("relation") }

    it "raises NotImplementedError when resolve is called" do
      expect { scope.resolve }.to raise_error(NotImplementedError, /resolve is not implemented/)
    end
  end
end
