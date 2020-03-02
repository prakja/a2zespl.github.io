class AddColumnTopic < ActiveRecord::Migration[5.2]
  def change
    add_column "public.Topic", :sectionReady, :boolean, default: false
  end
end
