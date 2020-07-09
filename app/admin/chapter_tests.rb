ActiveAdmin.register ChapterTest do
  remove_filter :topic, :test
  controller do
    def scoped_collection
      super.includes(:topic, :test)
    end
  end
end
