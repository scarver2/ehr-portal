# spec/requests/graphql_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GraphQL", type: :request do
  let(:headers) { { "Content-Type" => "application/json", "Accept" => "application/json" } }

  def gql(query, variables: {})
    post "/graphql", params: { query: query, variables: variables }.to_json, headers: headers
    JSON.parse(response.body)
  end

  describe "POST /graphql" do
    it "returns 200" do
      gql("{ providers { id } }")
      expect(response).to have_http_status(:ok)
    end

    it "returns JSON" do
      gql("{ providers { id } }")
      expect(response.content_type).to include("application/json")
    end
  end

  describe "providers query" do
    let!(:providers) { create_list(:provider, 3) }

    subject(:result) { gql("{ providers { id firstName lastName npi specialty { id name } clinicName } }") }

    it "returns no errors" do
      expect(result["errors"]).to be_nil
    end

    it "returns all providers ordered by last name" do
      expect(result.dig("data", "providers").length).to eq(3)
    end

    it "includes expected fields" do
      record = result.dig("data", "providers").first
      expect(record.keys).to include("id", "firstName", "lastName", "npi", "specialty", "clinicName")
    end
  end

  describe "provider query" do
    let!(:provider) { create(:provider, first_name: "Jane", last_name: "Doe") }

    subject(:result) do
      gql(
        "query GetProvider($id: ID!) { provider(id: $id) { id firstName lastName fullName npi specialty { id name } clinicName } }",
        variables: { id: provider.id.to_s }
      )
    end

    it "returns no errors" do
      expect(result["errors"]).to be_nil
    end

    it "returns the correct provider" do
      data = result.dig("data", "provider")
      expect(data["firstName"]).to eq("Jane")
      expect(data["lastName"]).to eq("Doe")
    end

    it "resolves fullName" do
      expect(result.dig("data", "provider", "fullName")).to eq("Jane Doe")
    end

    context "with a non-existent id" do
      subject(:result) do
        gql("query GetProvider($id: ID!) { provider(id: $id) { id } }", variables: { id: "0" })
      end

      it "returns no errors" do
        expect(result["errors"]).to be_nil
      end

      it "returns null for the provider" do
        expect(result.dig("data", "provider")).to be_nil
      end
    end
  end

  describe "node query" do
    let!(:provider) { create(:provider, first_name: "Jane", last_name: "Doe") }

    # Selecting `id` bare on a Node interface field triggers NodeBehaviors#id,
    # which conflicts with ProviderType's integer id field. Use only the
    # type-scoped `... on Provider` fragment to avoid the collision.
    subject(:result) do
      gql(
        "query GetNode($id: ID!) { node(id: $id) { ... on Provider { firstName lastName } } }",
        variables: { id: provider.to_gid_param }
      )
    end

    it "returns no errors" do
      expect(result["errors"]).to be_nil
    end

    it "fetches a provider by its global id" do
      data = result.dig("data", "node")
      expect(data["firstName"]).to eq("Jane")
      expect(data["lastName"]).to eq("Doe")
    end
  end

  describe "nodes query" do
    let!(:provider_a) { create(:provider, first_name: "Alice") }
    let!(:provider_b) { create(:provider, first_name: "Bob") }

    subject(:result) do
      gql(
        "query GetNodes($ids: [ID!]!) { nodes(ids: $ids) { ... on Provider { firstName } } }",
        variables: { ids: [provider_a.to_gid_param, provider_b.to_gid_param] }
      )
    end

    it "returns no errors" do
      expect(result["errors"]).to be_nil
    end

    it "fetches multiple providers by their global ids" do
      names = result.dig("data", "nodes").map { |n| n["firstName"] }
      expect(names).to contain_exactly("Alice", "Bob")
    end
  end

  describe "invalid query" do
    subject(:result) { gql("{ nonExistentField }") }

    it "returns errors" do
      expect(result["errors"]).to be_present
    end

    it "returns 200 (GraphQL errors are not HTTP errors)" do
      result
      expect(response).to have_http_status(:ok)
    end
  end
end
