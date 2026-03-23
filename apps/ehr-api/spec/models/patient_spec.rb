# spec/models/patient_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Patient do
  subject(:patient) { build(:patient) }

  it { is_expected.to be_valid }

  describe 'associations' do
    it 'belongs to a user (optional)' do
      p = create(:patient)
      expect(p.user).to be_a(User)
    end

    it 'can exist without a user account' do
      p = build(:patient, :without_user)
      expect(p).to be_valid
    end

    it 'has many encounters destroyed with it' do
      p = create(:patient)
      create(:encounter, patient: p)
      expect { p.destroy }.to change(Encounter, :count).by(-1)
    end
  end

  describe 'validations' do
    context 'without first_name' do
      subject { build(:patient, first_name: nil) }

      it { is_expected.not_to be_valid }
    end

    context 'without last_name' do
      subject { build(:patient, last_name: nil) }

      it { is_expected.not_to be_valid }
    end

    context 'with a duplicate mrn' do
      subject { build(:patient, mrn: '12345678') }

      before { create(:patient, mrn: '12345678') }

      it { is_expected.not_to be_valid }
    end
  end

  describe '#full_name' do
    it 'returns first and last name joined' do
      p = build(:patient, first_name: 'Jane', last_name: 'Doe')
      expect(p.full_name).to eq('Jane Doe')
    end
  end

  describe '#age' do
    it 'returns nil when date_of_birth is blank' do
      patient.date_of_birth = nil
      expect(patient.age).to be_nil
    end

    it 'calculates age from date_of_birth' do
      patient.date_of_birth = Date.new(Time.zone.today.year - 30, 1, 1)
      expect(patient.age).to eq(30)
    end
  end

  describe '.search_by_name' do
    let!(:jane) { create(:patient, first_name: 'Jane',  last_name: 'Smith') }
    let!(:john) { create(:patient, first_name: 'John',  last_name: 'Smith') }
    let!(:mary) { create(:patient, first_name: 'Mary',  last_name: 'Jones') }

    it 'finds by first name prefix' do
      expect(described_class.search_by_name('jan')).to include(jane)
      expect(described_class.search_by_name('jan')).not_to include(john)
    end

    it 'finds by last name' do
      expect(described_class.search_by_name('smith')).to include(jane, john)
      expect(described_class.search_by_name('smith')).not_to include(mary)
    end
  end

  describe '.alphabetical' do
    it 'orders by last_name then first_name' do
      a = create(:patient, last_name: 'Aldrich',   first_name: 'Bob')
      z = create(:patient, last_name: 'Zimmerman', first_name: 'Amy')
      expect(described_class.alphabetical.first).to eq(a)
      expect(described_class.alphabetical.last).to eq(z)
    end
  end

  describe '.ransackable_attributes' do
    it 'includes searchable fields' do
      expect(described_class.ransackable_attributes).to include('first_name', 'last_name', 'mrn', 'date_of_birth')
    end
  end

  describe '.ransackable_associations' do
    it 'includes associated models' do
      expect(described_class.ransackable_associations).to include('encounters', 'user')
    end
  end
end
