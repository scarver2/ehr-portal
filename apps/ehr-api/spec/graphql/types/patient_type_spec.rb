# spec/graphql/types/patient_type_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Types::PatientType do
  subject(:fields) { described_class.fields }

  it {
    is_expected.to include(
      "id", "firstName", "lastName", "fullName",
      "dateOfBirth", "age", "gender", "mrn",
      "phone", "address",
      "emergencyContactName", "emergencyContactPhone",
      "createdAt", "updatedAt", "encounters"
    )
  }

  describe "field nullability" do
    it "marks id as non-null" do
      expect(fields["id"].type.to_type_signature).to include("!")
    end

    it "marks firstName as non-null" do
      expect(fields["firstName"].type.to_type_signature).to include("!")
    end

    it "marks lastName as non-null" do
      expect(fields["lastName"].type.to_type_signature).to include("!")
    end

    it "marks fullName as non-null" do
      expect(fields["fullName"].type.to_type_signature).to include("!")
    end

    it "marks createdAt as non-null" do
      expect(fields["createdAt"].type.to_type_signature).to include("!")
    end

    it "marks updatedAt as non-null" do
      expect(fields["updatedAt"].type.to_type_signature).to include("!")
    end

    it "allows dateOfBirth to be null" do
      expect(fields["dateOfBirth"].type.to_type_signature).not_to end_with("!")
    end

    it "allows age to be null" do
      expect(fields["age"].type.to_type_signature).not_to end_with("!")
    end

    it "allows gender to be null" do
      expect(fields["gender"].type.to_type_signature).not_to end_with("!")
    end

    it "allows mrn to be null" do
      expect(fields["mrn"].type.to_type_signature).not_to end_with("!")
    end
  end

  describe "#fullName field" do
    let(:patient) { create(:patient, first_name: "Maria", last_name: "Santos") }

    subject(:result) do
      EhrApiSchema.execute(
        "{ patient(id: \"#{patient.id}\") { fullName } }",
        context: {}
      )
    end

    it "returns no errors" do
      expect(result["errors"]).to be_nil
    end

    it "concatenates first and last name" do
      expect(result.dig("data", "patient", "fullName")).to eq("Maria Santos")
    end
  end

  describe "#encounters field" do
    let(:encounter) { create(:encounter) }
    let(:patient)   { encounter.patient }

    subject(:result) do
      EhrApiSchema.execute(
        "{ patient(id: \"#{patient.id}\") { encounters { id } } }",
        context: {}
      )
    end

    it "returns no errors" do
      expect(result["errors"]).to be_nil
    end

    it "returns the patient encounters" do
      ids = result.dig("data", "patient", "encounters").map { |e| e["id"] }
      expect(ids).to include(encounter.id.to_s)
    end
  end
end
