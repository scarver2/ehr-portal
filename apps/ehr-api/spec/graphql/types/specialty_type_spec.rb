# spec/graphql/types/specialty_type_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Types::SpecialtyType do
  subject(:fields) { described_class.fields }

  it { is_expected.to include("id", "name", "category", "createdAt", "updatedAt") }

  describe "field nullability" do
    it "marks id as non-null" do
      expect(fields["id"].type.to_type_signature).to include("!")
    end

    it "marks name as non-null" do
      expect(fields["name"].type.to_type_signature).to include("!")
    end

    it "marks createdAt as non-null" do
      expect(fields["createdAt"].type.to_type_signature).to include("!")
    end

    it "marks updatedAt as non-null" do
      expect(fields["updatedAt"].type.to_type_signature).to include("!")
    end

    it "allows category to be null" do
      expect(fields["category"].type.to_type_signature).not_to end_with("!")
    end
  end

  describe "specialty query" do
    let(:specialty) { create(:specialty, name: "Neurology", category: "Medical") }

    subject(:result) do
      EhrApiSchema.execute(
        "{ specialty(id: \"#{specialty.id}\") { name category } }",
        context: {}
      )
    end

    it "returns no errors" do
      expect(result["errors"]).to be_nil
    end

    it "returns the specialty name" do
      expect(result.dig("data", "specialty", "name")).to eq("Neurology")
    end

    it "returns the category" do
      expect(result.dig("data", "specialty", "category")).to eq("Medical")
    end
  end
end
