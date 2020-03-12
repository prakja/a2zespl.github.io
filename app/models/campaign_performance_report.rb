class CampaignPerformanceReport < ApplicationRecord
  self.table_name = "CAMPAIGN_PERFORMANCE_REPORT"
  default_scope {where(campaignState: "enabled")}
  scope :yesterday, -> {
    self.where(:day => 1.day.ago.midnight..Date.today.midnight)
  }
end
