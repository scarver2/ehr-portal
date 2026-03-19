# frozen_string_literal: true

ActiveAdmin.register Vital do
  belongs_to :encounter, optional: true

  permit_params :encounter_id, :vital_type, :value, :unit, :observed_at, :notes

  filter :encounter
  filter :vital_type, as: :select, collection: Vital.vital_types.keys
  filter :observed_at

  index do
    selectable_column
    id_column
    column :encounter
    column :vital_type
    column :value
    column :unit
    column :observed_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :encounter
      row :vital_type
      row :value
      row :unit
      row :observed_at
      row :notes
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :encounter
      f.input :vital_type, as: :select, collection: Vital.vital_types.keys
      f.input :value
      f.input :unit
      f.input :observed_at, as: :datetime_picker
      f.input :notes
    end
    f.actions
  end
end
