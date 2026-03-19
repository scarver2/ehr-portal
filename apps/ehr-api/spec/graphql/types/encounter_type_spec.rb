# spec/graphql/types/encounter_type_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Types::EncounterType do
  subject(:fields) { described_class.fields }

  it {
    is_expected.to include(
      "id", "encounterType", "status", "encounteredAt",
      "chiefComplaint", "notes",
      "createdAt", "updatedAt",
      "patient", "provider", "vitals", "diagnoses"
    )
  }

  describe "field nullability" do
    it "marks id as non-null" do
      expect(fields["id"].type.to_type_signature).to include("!")
    end

    it "marks encounterType as non-null" do
      expect(fields["encounterType"].type.to_type_signature).to include("!")
    end

    it "marks status as non-null" do
      expect(fields["status"].type.to_type_signature).to include("!")
    end

    it "marks encounteredAt as non-null" do
      expect(fields["encounteredAt"].type.to_type_signature).to include("!")
    end

    it "marks createdAt as non-null" do
      expect(fields["createdAt"].type.to_type_signature).to include("!")
    end

    it "marks updatedAt as non-null" do
      expect(fields["updatedAt"].type.to_type_signature).to include("!")
    end

    it "allows chiefComplaint to be null" do
      expect(fields["chiefComplaint"].type.to_type_signature).not_to end_with("!")
    end

    it "allows notes to be null" do
      expect(fields["notes"].type.to_type_signature).not_to end_with("!")
    end
  end

  describe "#vitals field" do
    let(:encounter) { create(:encounter) }
    let!(:vital)    { create(:vital, encounter: encounter) }

    subject(:result) do
      EhrApiSchema.execute(
        "{ encounter(id: \"#{encounter.id}\") { vitals { vitalType value } } }",
        context: {}
      )
    end

    it "returns no errors" do
      expect(result["errors"]).to be_nil
    end

    it "returns vitals for the encounter" do
      types = result.dig("data", "encounter", "vitals").map { |v| v["vitalType"] }
      expect(types).to include(vital.vital_type)
    end
  end

  describe "#diagnoses field" do
    let(:encounter)  { create(:encounter) }
    let!(:diagnosis) { create(:diagnosis, encounter: encounter) }

    subject(:result) do
      EhrApiSchema.execute(
        "{ encounter(id: \"#{encounter.id}\") { diagnoses { icd10Code description } } }",
        context: {}
      )
    end

    it "returns no errors" do
      expect(result["errors"]).to be_nil
    end

    it "returns diagnoses for the encounter" do
      codes = result.dig("data", "encounter", "diagnoses").map { |d| d["icd10Code"] }
      expect(codes).to include(diagnosis.icd10_code)
    end
  end
end
