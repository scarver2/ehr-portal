# frozen_string_literal: true

require "rails_helper"

RSpec.describe Diagnosis, type: :model do
  subject(:diagnosis) { build(:diagnosis) }

  it { is_expected.to be_valid }

  describe "associations" do
    it "belongs to an encounter" do
      dx = create(:diagnosis)
      expect(dx.encounter).to be_a(Encounter)
    end
  end

  describe "validations" do
    context "without icd10_code" do
      subject { build(:diagnosis, icd10_code: nil) }

      it { is_expected.not_to be_valid }
    end

    context "without description" do
      subject { build(:diagnosis, description: nil) }

      it { is_expected.not_to be_valid }
    end

    context "without diagnosed_at" do
      subject { build(:diagnosis, diagnosed_at: nil) }

      it { is_expected.not_to be_valid }
    end

    describe "icd10_code format" do
      it "accepts a valid code without decimal" do
        diagnosis.icd10_code = "I10"
        expect(diagnosis).to be_valid
      end

      it "accepts a valid code with decimal extension" do
        diagnosis.icd10_code = "E11.9"
        expect(diagnosis).to be_valid
      end

      it "rejects a plain text string" do
        diagnosis.icd10_code = "hypertension"
        expect(diagnosis).not_to be_valid
      end

      it "rejects a code starting with a lowercase letter" do
        diagnosis.icd10_code = "i10"
        expect(diagnosis).not_to be_valid
      end
    end
  end

  describe "enums" do
    it "defines status values" do
      expect(Diagnosis.statuses.keys).to match_array(%w[active resolved chronic ruled_out])
    end

    context "with an invalid status" do
      it "is invalid" do
        diagnosis.write_attribute(:status, "pending")
        expect(diagnosis).not_to be_valid
      end
    end
  end

  describe "scopes" do
    let!(:active_dx)   { create(:diagnosis, :active) }
    let!(:chronic_dx)  { create(:diagnosis, :hypertension) }
    let!(:resolved_dx) { create(:diagnosis, :resolved, diagnosed_at: 30.days.ago) }

    it ".active filters active diagnoses" do
      expect(Diagnosis.active).to include(active_dx)
      expect(Diagnosis.active).not_to include(resolved_dx)
    end

    it ".chronic filters chronic diagnoses" do
      expect(Diagnosis.chronic).to contain_exactly(chronic_dx)
    end

    it ".recent orders by diagnosed_at descending" do
      expect(Diagnosis.recent.first).not_to eq(resolved_dx)
    end

    it ".by_code filters by ICD-10 code" do
      expect(Diagnosis.by_code("I10")).to contain_exactly(chronic_dx)
    end
  end
end
