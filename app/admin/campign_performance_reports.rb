ActiveAdmin.register CampaignPerformanceReport do
  config.sort_order = 'day_desc'
  scope :yesterday
  action_item :see_day_wise_campaign_report, only: :index do
    link_to 'Day Wise Campaign Report', '../../google_ads/report'
  end

  index do
    column :day
    column :_sdc_sequence
    column (:campaign) { |campaign_performance_report| raw(campaign_performance_report.campaign)  }
    column (:cost) { |campaign_performance_report| raw(campaign_performance_report.cost/1000000).to_f  }
    column (:avgCost) { |campaign_performance_report| raw(campaign_performance_report.avgCost/1000000).to_f  }
    column (:campaignState) { |campaign_performance_report| raw(campaign_performance_report.campaignState)  }
    column (:convRate) { |campaign_performance_report| raw(campaign_performance_report.convRate)  }
    column (:conversions) { |campaign_performance_report| raw(campaign_performance_report.conversions)  }
    column (:costConv) { |campaign_performance_report| raw(campaign_performance_report.costConv/1000000).to_f  }
    column (:impressions) { |campaign_performance_report| raw(campaign_performance_report.impressions)  }
    column (:interactions) { |campaign_performance_report| raw(campaign_performance_report.interactions)  }
    column (:interactionRate) { |campaign_performance_report| raw(campaign_performance_report.interactionRate)  }
    column :_sdc_customer_id
    column :_sdc_extracted_at
    actions
  end
end
