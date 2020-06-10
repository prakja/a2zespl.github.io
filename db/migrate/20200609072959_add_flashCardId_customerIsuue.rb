class AddFlashCardIdIdCustomerIssue < ActiveRecord::Migration[5.2]
  def change
    add_column "CustomerIssue", "flashCardId", :integer, default: nil
  end
end
