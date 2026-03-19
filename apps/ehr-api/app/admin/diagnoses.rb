# frozen_string_literal: true

ActiveAdmin.register Diagnosis do
  belongs_to :encounter, optional: true

  permit_params :encounter_id, :icd10_code, :description, :status, :diagnosed_at, :notes

  filter :encounter
  filter :icd10_code
  filter :status, as: :select, collection: Diagnosis.statuses.keys
  filter :diagnosed_at

  index do
    selectable_column
    id_column
    column :encounter
    column :icd10_code
    column :description
    column :status
    column :diagnosed_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :encounter
      row :icd10_code
      row :description
      row :status
      row :diagnosed_at
      row :notes
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :encounter
      f.input :icd10_code
      f.input :description
      f.input :status, as: :select, collection: Diagnosis.statuses.keys
      f.input :diagnosed_at, as: :datetime_picker
      f.input :notes
    end
    f.actions
  end
end
