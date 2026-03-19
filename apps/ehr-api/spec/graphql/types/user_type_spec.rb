# spec/graphql/types/user_type_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Types::UserType do
  subject(:fields) { described_class.fields }

  it { is_expected.to include("id", "email", "role", "createdAt", "updatedAt", "patient", "provider") }

  describe "field nullability" do
    it "marks id as non-null" do
      expect(fields["id"].type.to_type_signature).to include("!")
    end

    it "marks email as non-null" do
      expect(fields["email"].type.to_type_signature).to include("!")
    end

    it "marks role as non-null" do
      expect(fields["role"].type.to_type_signature).to include("!")
    end

    it "marks createdAt as non-null" do
      expect(fields["createdAt"].type.to_type_signature).to include("!")
    end

    it "marks updatedAt as non-null" do
      expect(fields["updatedAt"].type.to_type_signature).to include("!")
    end

    it "allows patient to be null" do
      expect(fields["patient"].type.to_type_signature).not_to end_with("!")
    end

    it "allows provider to be null" do
      expect(fields["provider"].type.to_type_signature).not_to end_with("!")
    end
  end

  describe "relationship field types" do
    it "patient field resolves to PatientType" do
      expect(fields["patient"].type.unwrap).to eq(Types::PatientType)
    end

    it "provider field resolves to ProviderType" do
      expect(fields["provider"].type.unwrap).to eq(Types::ProviderType)
    end
  end

  describe "AR-level relationship resolution" do
    context "when the user has a patient profile" do
      let(:user)     { create(:user, :patient) }
      let!(:patient) { create(:patient, user: user) }

      it "exposes the associated patient through the model" do
        expect(user.patient).to eq(patient)
      end

      it "destroying the user destroys the patient" do
        expect { user.destroy }.to change(Patient, :count).by(-1)
      end
    end

    context "when the user has no patient profile" do
      let(:user) { create(:user, :admin) }

      it "patient is nil" do
        expect(user.patient).to be_nil
      end
    end

    context "when the user has a provider profile" do
      let(:user)      { create(:user, :provider) }
      let!(:provider) { create(:provider, user: user) }

      it "exposes the associated provider through the model" do
        expect(user.provider).to eq(provider)
      end

      it "destroying the user nullifies the provider user_id" do
        user.destroy
        expect(provider.reload.user_id).to be_nil
      end
    end

    context "when the user has no provider profile" do
      let(:user) { create(:user, :patient) }

      it "provider is nil" do
        expect(user.provider).to be_nil
      end
    end
  end
end
