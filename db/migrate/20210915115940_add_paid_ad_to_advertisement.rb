class AddPaidAdToAdvertisement < ActiveRecord::Migration[5.2]
  def change
    add_column "Advertisement", :show_paid_user, :boolean, :default => false
  end
end
