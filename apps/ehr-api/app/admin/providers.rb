# apps/ehr-api/app/admin/providers.rb
# frozen_string_literal: true

ActiveAdmin.register Provider do
  permit_params :user_id, :specialty_id, :first_name, :last_name, :npi,
                :clinic_name, :city, :state, :zip

  filter :first_name
  filter :last_name
  filter :npi
  filter :specialty
  filter :clinic_name
  filter :city
  filter :state

  index do
    selectable_column
    id_column
    column(:name, &:full_name)
    column :specialty
    column :clinic_name
    column :npi
    column(:location, &:location)
    actions
  end

  show do
    attributes_table do
      row :id
      row :first_name
      row :last_name
      row :npi
      row :specialty
      row :clinic_name
      row :city
      row :state
      row :zip
      row :user
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs 'Identity' do
      f.input :first_name
      f.input :last_name
      f.input :npi
      f.input :specialty, as: :select,
                          collection: Specialty.alphabetical.map { |s| [s.name, s.id] },
                          include_blank: true
      f.input :clinic_name
    end

    f.inputs 'Location' do
      f.input :city
      f.input :state
      f.input :zip
    end

    f.inputs 'Account' do
      f.input :user, as: :select,
                     collection: User.provider_accounts.map { |u| [u.email, u.id] },
                     include_blank: true
    end

    f.actions
  end
end
