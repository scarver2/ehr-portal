# frozen_string_literal: true

ActiveAdmin.register Patient do
  permit_params :user_id, :first_name, :last_name, :date_of_birth, :gender,
                :mrn, :phone, :address,
                :emergency_contact_name, :emergency_contact_phone

  filter :first_name
  filter :last_name
  filter :mrn
  filter :date_of_birth
  filter :gender, as: :select, collection: %w[male female other prefer_not_to_say]
  filter :phone

  index do
    selectable_column
    id_column
    column :mrn
    column(:name, &:full_name)
    column :date_of_birth
    column :gender
    column :phone
    column(:encounters) { |p| p.encounters.count }
    actions
  end

  show do
    attributes_table do
      row :id
      row :mrn
      row :first_name
      row :last_name
      row(:age, &:age)
      row :date_of_birth
      row :gender
      row :phone
      row :address
      row :emergency_contact_name
      row :emergency_contact_phone
      row :user
      row :created_at
      row :updated_at
    end

    panel 'Encounters' do
      table_for patient.encounters.recent do
        column :encountered_at
        column :encounter_type
        column :status
        column :provider
        column :chief_complaint
        column('') { |e| link_to 'View', admin_encounter_path(e) }
      end
    end
  end

  form do |f|
    f.inputs 'Identity' do
      f.input :mrn
      f.input :first_name
      f.input :last_name
      f.input :date_of_birth, as: :date_picker
      f.input :gender, as: :select,
                       collection: %w[male female other prefer_not_to_say],
                       include_blank: true
    end

    f.inputs 'Contact' do
      f.input :phone
      f.input :address
      f.input :emergency_contact_name
      f.input :emergency_contact_phone
    end

    f.inputs 'Account' do
      f.input :user, as: :select,
                     collection: User.order(:email).map { |u| [u.email, u.id] },
                     include_blank: true
    end

    f.actions
  end
end
