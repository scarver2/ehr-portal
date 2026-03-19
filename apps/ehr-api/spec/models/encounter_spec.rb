# spec/models/encounter_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Encounter, type: :model do
  subject(:encounter) { build(:encounter) }

  it { is_expected.to be_valid }

  describe "associations" do
    it "belongs to a patient (Patient)" do
      enc = create(:encounter)
      expect(enc.patient).to be_a(Patient)
    end

    it "belongs to a provider (Provider)" do
      enc = create(:encounter)
      expect(enc.provider).to be_a(Provider)
    end

    it "has many vitals destroyed with it" do
      enc = create(:encounter)
      create(:vital, encounter: enc)
      expect { enc.destroy }.to change(Vital, :count).by(-1)
    end

    it "has many diagnoses destroyed with it" do
      enc = create(:encounter)
      create(:diagnosis, encounter: enc)
      expect { enc.destroy }.to change(Diagnosis, :count).by(-1)
    end
  end

  describe "validations" do
    context "without encountered_at" do
      subject { build(:encounter, encountered_at: nil) }

      it { is_expected.not_to be_valid }
    end

    context "without encounter_type" do
      subject { build(:encounter, encounter_type: nil) }

      it { is_expected.not_to be_valid }
    end

    context "without status" do
      subject { build(:encounter, status: nil) }

      it { is_expected.not_to be_valid }
    end
  end

  describe "enums" do
    it "defines encounter_type values" do
      expect(Encounter.encounter_types.keys).to match_array(
        %w[office_visit telehealth emergency follow_up annual_exam]
      )
    end

    it "defines status values" do
      expect(Encounter.statuses.keys).to match_array(
        %w[scheduled in_progress completed cancelled]
      )
    end

    context "with an invalid encounter_type" do
      it "is invalid" do
        encounter.write_attribute(:encounter_type, "house_call")
        expect(encounter).not_to be_valid
      end
    end

    context "with an invalid status" do
      it "is invalid" do
        encounter.write_attribute(:status, "pending")
        expect(encounter).not_to be_valid
      end
    end

    describe "encounter_type predicates" do
      it { expect(build(:encounter, :office_visit)).to  be_office_visit }
      it { expect(build(:encounter, :telehealth)).to    be_telehealth }
      it { expect(build(:encounter, :emergency)).to     be_emergency }
      it { expect(build(:encounter, :follow_up)).to     be_follow_up }
      it { expect(build(:encounter, :annual_exam)).to   be_annual_exam }
    end

    describe "status predicates" do
      it { expect(build(:encounter, :scheduled)).to    be_scheduled }
      it { expect(build(:encounter, :in_progress)).to  be_in_progress }
      it { expect(build(:encounter, :completed)).to    be_completed }
      it { expect(build(:encounter, :cancelled)).to    be_cancelled }
    end
  end

  describe "scopes" do
    let!(:old_encounter) { create(:encounter, :completed, encountered_at: 7.days.ago) }
    let!(:new_encounter) { create(:encounter, :scheduled, encountered_at: 1.hour.ago) }

    it ".recent orders by encountered_at descending" do
      expect(Encounter.recent.first).to eq(new_encounter)
    end

    it ".completed filters by completed status" do
      expect(Encounter.completed).to contain_exactly(old_encounter)
    end

    it ".for_patient filters by patient" do
      expect(Encounter.for_patient(new_encounter.patient)).to include(new_encounter)
      expect(Encounter.for_patient(new_encounter.patient)).not_to include(old_encounter)
    end

    it ".for_provider filters by provider" do
      expect(Encounter.for_provider(new_encounter.provider)).to include(new_encounter)
      expect(Encounter.for_provider(new_encounter.provider)).not_to include(old_encounter)
    end
  end

  describe ".ransackable_attributes" do
    it "includes key searchable fields" do
      expect(Encounter.ransackable_attributes).to include("status", "encounter_type", "encountered_at")
    end
  end

  describe ".ransackable_associations" do
    it "includes associated models" do
      expect(Encounter.ransackable_associations).to include("patient", "provider", "vitals", "diagnoses")
    end
  end
end
