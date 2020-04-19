ActiveAdmin.register ChapterTest do
  remove_filter :chapter, :test
  controller do
    def scoped_collection
      super.includes(:chapter, :test)
    end
  end
end
