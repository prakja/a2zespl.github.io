class GoogleAdsController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token


  def report
    if not current_admin_user
      redirect_to "/admin/login"
      return
    end

    @campaign_reports = {}
    @campaign_reports = CampaignPerformanceReport.where(['day > ? and _sdc_report_datetime > ?', 30.days.ago, Time.now.midnight]).group('day').order('day desc').pluck("day, sum(cost) as total_cost")

    @report_data = {}

    @campaign_reports.each do |report|
      @report_data[report[0]] = [(report[1]/1000000).to_f]
    end

  end
end
