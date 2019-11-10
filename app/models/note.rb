class Note < ApplicationRecord
 self.table_name = "Note"
 attribute :createdAt, :datetime, default: Time.now
 attribute :updatedAt, :datetime, default: Time.now

  has_one :video_annotation,  -> { where(annotationType: "Note") }, class_name: "VideoAnnotation", foreign_key: "annotationId"
  has_one :video, through: :video_annotation

  def githubEpubContent
    if(self.epubURL)
      return 'https://github.com/jayprakash1/ncert_epubs/tree/master/' + self.epubURL.split("neetprep/")[1].gsub('content.opf','Text')
    else
      return "#"
    end
  end
end
