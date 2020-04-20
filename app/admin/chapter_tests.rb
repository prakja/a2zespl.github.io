ActiveAdmin.register ChapterTest do
  remove_filter :topic, :test
  controller do
    def scoped_collection
      super.includes(:chapter, :test)
    end
  end
end
