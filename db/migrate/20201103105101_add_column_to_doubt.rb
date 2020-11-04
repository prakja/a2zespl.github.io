class AddColumnToDoubt < ActiveRecord::Migration[5.2]
  def change
    add_column "Doubt", 'doubtSolved', :boolean, :default => false
    #Ex:- :default =>''
  end
end
