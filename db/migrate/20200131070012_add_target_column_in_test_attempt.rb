class AddTargetColumnInTestAttempt < ActiveRecord::Migration[5.2]
  def change
    add_column "TestAttempt", "nextTargetScore", :integer, default: nil
    add_column "TestAttempt", "nextTargetDate", :datetime, default: nil
  end
end
