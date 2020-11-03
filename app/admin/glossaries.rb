ActiveAdmin.register Glossary do

  permit_params :word, :translation, :language, :createdAt, :updatedAt, chapter_glossaries_attributes: [:id, :chapterId, :glossaryId, :createdAt, :updatedAt, :_destroy]
  remove_filter :chapters
  
end
