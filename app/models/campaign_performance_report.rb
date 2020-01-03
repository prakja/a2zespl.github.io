class CampaignPerformanceReport < ApplicationRecord
 self.table_name = "CAMPAIGN_PERFORMANCE_REPORT"
 default_scope {where(campaignState: "enabled")}
end
