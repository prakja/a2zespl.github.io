class Section < ApplicationRecord
 self.table_name = "Section"

 attribute :createdAt, :datetime, default: Time.now
 attribute :updatedAt, :datetime, default: Time.now

 belongs_to :topic, class_name: "Topic", foreign_key: "chapterId", optional: false
 has_many :contents, class_name: "SectionContent", foreign_key: "sectionId"
 accepts_nested_attributes_for :contents, allow_destroy: true
end
