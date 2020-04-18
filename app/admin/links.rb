ActiveAdmin.register_page "Links" do

  breadcrumb do
    ['Admin', 'Links']
  end

  controller do 
    def index
      render :layout => 'active_admin'
    end
  end
    
end
