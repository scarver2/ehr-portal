# spec/models/provider_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Provider, type: :model do
  subject(:provider) { build(:provider) }

  its(:first_name)  { is_expected.to be_present }
  its(:last_name)   { is_expected.to be_present }
  its(:npi)         { is_expected.to match(/\A\d{10}\z/) }
  its(:clinic_name) { is_expected.to be_present }

  describe "associations" do
    it "belongs to a specialty (optional)" do
      p = create(:provider)
      expect(p.specialty).to be_a(Specialty)
    end

    it "can exist without a specialty" do
      p = build(:provider, specialty: nil)
      expect(p).to be_valid
    end
  end

  describe "#full_name" do
    it "returns first and last name joined" do
      p = build(:provider, first_name: "Alice", last_name: "Wong")
      expect(p.full_name).to eq("Alice Wong")
    end
  end

  describe "#location" do
    it "returns city and state joined" do
      p = build(:provider, city: "Austin", state: "TX")
      expect(p.location).to eq("Austin, TX")
    end

    it "handles missing city gracefully" do
      p = build(:provider, city: nil, state: "TX")
      expect(p.location).to eq("TX")
    end

    it "returns blank string when both are nil" do
      p = build(:provider, city: nil, state: nil)
      expect(p.location).to eq("")
    end
  end

  describe ".ransackable_attributes" do
    subject { described_class.ransackable_attributes }

    it { is_expected.to include("first_name", "last_name", "npi", "specialty_id", "clinic_name") }
    it { is_expected.not_to include("encrypted_password") }
    it { is_expected.not_to include("specialty") }
  end
end
