# apps/ehr-api/app/admin/specialties.rb
# frozen_string_literal: true

ActiveAdmin.register Specialty do
  permit_params :name, :category

  filter :name
  filter :category, as: :select,
                    collection: Specialty.distinct.pluck(:category).compact.sort

  index do
    selectable_column
    id_column
    column :name
    column :category
    column(:providers) { |s| s.providers.count }
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :category
      row :created_at
      row :updated_at
    end

    panel "Providers" do
      table_for specialty.providers.order(:last_name) do
        column :full_name
        column :clinic_name
        column(:location) { |p| p.location }
        column("") { |p| link_to "View", admin_provider_path(p) }
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :category, as: :select,
              collection: %w[Clinical Diagnostic Medical Primary\ Care Surgical],
              include_blank: true
    end
    f.actions
  end
end
