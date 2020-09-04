class SectionContent < ApplicationRecord
  self.table_name = "SectionContent"
  has_paper_trail
  # acts_as_list scope: :section

  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now

  belongs_to :section, class_name: "Section", foreign_key: "sectionId", optional: false
  attr_accessor :contents_title, :contents_contentId, :contents_contentType, :contents_position
end
