class Post < ApplicationRecord
  self.table_name = "Post"
  attribute :createdAt, :datetime, default: Time.now
  attribute :updatedAt, :datetime, default: Time.now
end
