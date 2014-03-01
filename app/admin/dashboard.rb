ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Top 5 Delegations" do
          ul do
            Delegation.order('updated_at DESC').limit(5).map do |delegation|
              li link_to(delegation.name, admin_delegation_path(delegation))
            end
          end
        end
      end

      column do
        panel "Info" do
          para "Welcome to ActiveAdmin."
        end
      end
    end
  end # content
end
