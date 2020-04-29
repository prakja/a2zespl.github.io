class AppVersion < ApplicationRecord
 self.table_name = "AppVersion"
 attribute :createdAt, :datetime, default: Time.now
 attribute :updatedAt, :datetime, default: Time.now
end
