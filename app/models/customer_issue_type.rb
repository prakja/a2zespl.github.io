class CustomerIssueType < ApplicationRecord
  self.table_name = "CustomerIssueType"

  def name
    return self.displayName
  end
end
