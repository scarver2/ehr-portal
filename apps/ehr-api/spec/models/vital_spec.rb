# frozen_string_literal: true

require "rails_helper"

RSpec.describe Vital, type: :model do
  subject(:vital) { build(:vital) }

  it { is_expected.to be_valid }

  describe "associations" do
    it "belongs to an encounter" do
      v = create(:vital)
      expect(v.encounter).to be_a(Encounter)
    end
  end

  describe "validations" do
    context "without vital_type" do
      subject { build(:vital, vital_type: nil) }

      it { is_expected.not_to be_valid }
    end

    context "without value" do
      subject { build(:vital, value: nil) }

      it { is_expected.not_to be_valid }
    end

    context "without observed_at" do
      subject { build(:vital, observed_at: nil) }

      it { is_expected.not_to be_valid }
    end
  end

  describe "enums" do
    it "defines all vital_type values" do
      expect(Vital.vital_types.keys).to match_array(
        %w[blood_pressure heart_rate temperature weight height oxygen_saturation respiratory_rate bmi]
      )
    end

    context "with an invalid vital_type" do
      it "is invalid" do
        vital.write_attribute(:vital_type, "cortisol_level")
        expect(vital).not_to be_valid
      end
    end
  end

  describe "UNITS constant" do
    it "defines a unit for every vital type" do
      Vital.vital_types.each_key do |type|
        expect(Vital::UNITS).to have_key(type.to_sym)
      end
    end
  end

  describe "scopes" do
    let!(:bp_vital)   { create(:vital, :blood_pressure, observed_at: 2.hours.ago) }
    let!(:hr_vital)   { create(:vital, :heart_rate,     observed_at: 1.hour.ago) }

    it ".recent orders by observed_at descending" do
      expect(Vital.recent.first).to eq(hr_vital)
    end

    it ".by_type filters by vital_type" do
      expect(Vital.by_type(:blood_pressure)).to contain_exactly(bp_vital)
    end
  end
end
