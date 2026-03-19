# frozen_string_literal: true

# apps/ehr-api/app/admin/status.rb

ActiveAdmin.register_page "Status" do
  menu priority: 99, label: "Status"

  content title: "Status" do
    panel "Observability" do
      table_for [{}] do
        column("Service") { "Honeybadger" }
        column("Dashboard") do
          link_to "Open Insights Dashboard",
                  "https://app.honeybadger.io/projects/138326/insights/dashboards",
                  target: "_blank",
                  rel: "noopener noreferrer"
        end
      end
    end
  end
end
