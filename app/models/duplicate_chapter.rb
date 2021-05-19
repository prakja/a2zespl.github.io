class DuplicateChapter < ApplicationRecord
  self.table_name = "DuplicateChapter"

  def self.duplicate?(dupId, origId)
    return self.where(dupId: dupId, origId: origId).present?
  end

  def self.newDuplicateChapter(oldDupId, newOrigId)
    return ActiveRecord::Base.connection.execute('select "newDuplicateChapter"(' + oldDupId.to_s + ", " + newOrigId.to_s + ');')[0]["newDuplicateChapter"]
  end

end
