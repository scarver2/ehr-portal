# frozen_string_literal: true

ActiveAdmin.register Encounter do
  permit_params :patient_id, :provider_id, :encounter_type, :status,
                :encountered_at, :chief_complaint, :notes

  filter :patient,        as: :select
  filter :provider,       as: :select
  filter :encounter_type, as: :select, collection: Encounter.encounter_types.keys
  filter :status,         as: :select, collection: Encounter.statuses.keys
  filter :encountered_at
  filter :chief_complaint

  index do
    selectable_column
    id_column
    column :patient
    column :provider
    column :encounter_type
    column :status
    column :encountered_at
    column :chief_complaint
    actions
  end

  show do
    attributes_table do
      row :id
      row :patient
      row :provider
      row :encounter_type
      row :status
      row :encountered_at
      row :chief_complaint
      row :notes
      row :created_at
      row :updated_at
    end

    panel 'Vitals' do
      table_for encounter.vitals.recent do
        column :vital_type
        column :value
        column :unit
        column :observed_at
      end
    end

    panel 'Diagnoses' do
      table_for encounter.diagnoses.recent do
        column :icd10_code
        column :description
        column :status
        column :diagnosed_at
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :patient,        as: :select, collection: Patient.alphabetical.map { |p| [p.full_name, p.id] }
      f.input :provider,       as: :select, collection: Provider.order(:last_name)
      f.input :encounter_type, as: :select, collection: Encounter.encounter_types.keys
      f.input :status,         as: :select, collection: Encounter.statuses.keys
      f.input :encountered_at, as: :datetime_picker
      f.input :chief_complaint
      f.input :notes
    end
    f.actions
  end
end
