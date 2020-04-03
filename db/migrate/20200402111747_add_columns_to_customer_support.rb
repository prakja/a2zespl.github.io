class AddColumnsToCustomerSupport < ActiveRecord::Migration[5.2]
  def change
    add_column "public.CustomerSupport", :email, :string
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
    add_column "public.CustomerSupport", :userData, :string
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
