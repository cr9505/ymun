ActiveAdmin.register_page "Sync Committee Assignments" do
  content do
    para "Here you can specify a Google Doc that has committee assignment information."
    para <<-EOS
    You may do this non-destructively as many times as you would like, but any
    character's whose names are changed will have to be reassigned to delegates
    by advisors.
    EOS
    
    form action: admin_sync_committee_assignments_sync_path, method: :post do
      para do
        label "Google Doc URL"
        input name: :google_doc_url, type: :text, label: "Google Spreadsheet URL"
      end
      para do
        label "Username"
        input name: :username, type: :text
      end
      para do
        label "Password"
        input name: :password, type: :password
      end
      input name: :format, type: :hidden, value: 'ymge'
      input name: :authenticity_token, type: :hidden, value: 'form_authenticity_token'

      button "Sync!", type: :submit
    end
  end
  
  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end

  page_action :sync, method: :post do
    committee_parsers = {
      'ymge' => CommitteeParser::YMGE
      # 'ymun' => CommitteeParser::YMUN
    }
    committee_parser = committee_parsers[params[:format]]
    google_doc = params[:google_doc_url]
    username = params[:username]
    password = params[:password]
    sync_errors = Committee.sync_with_drive(google_doc, username, password, committee_parser)
    if sync_errors
      redirect_to admin_committees_path, error: sync_errors.join('<br />').html_safe
    else
      redirect_to admin_committees_path, notice: 'Committee Assignments successfully synced!'
    end
  end

  
end
