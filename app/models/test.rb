class Test < ApplicationRecord
 self.table_name = "Test"

 attribute :createdAt, :datetime, default: Time.now
 attribute :updatedAt, :datetime, default: Time.now
end
