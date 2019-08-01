class AddSequeceIdToQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :sequeceId, :integer
  end
end
