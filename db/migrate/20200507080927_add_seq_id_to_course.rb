class AddSeqIdToCourse < ActiveRecord::Migration[5.2]
  def change
    add_column "Course", :seqId, :integer
  end
end
