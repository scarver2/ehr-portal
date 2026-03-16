# apps/ehr-api/app/admin/providers.rb

ActiveAdmin.register Provider do
  permit_params :first_name, :last_name
end
