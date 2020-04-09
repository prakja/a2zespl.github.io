module ActiveAdmin
  class Comment  < ActiveRecord::Base
    after_create :send_notification

    def send_notification
      p "In notification block"
      if self.resource_type == "CustomerSupport"
        customer_support = CustomerSupport.find(self.resource_id)
        user_id = customer_support.userId
        user = User.find(user_id)
        comment_body = self.body
        p "Checking body and issue"
        if not customer_support.resolved? and comment_body.start_with?("Resolved:")
          customer_support.resolved = true
          customer_support.save
          HTTParty.post(
            Rails.configuration.node_site_url + "api/v1/job/importantNewsNotification",
            body: {
              studentType: 'Selected',
              message: comment_body.gsub("Resolved:", "").squish,
              title: "Issue Resolved",
              imageUrl: nil,
              contextType: "LinkUrl",
              actionUrl: nil,
              courseId: nil,
              userId: user_id
          })
          HTTParty.post(
            Rails.configuration.node_site_url + "/api/v1/webhook/sendEmail",
            body: {
              to: user.email,
              subject: "Issue Resolved",
              message: comment_body.gsub("Resolved:", "").squish,
              altText: ""
          })
        else
          p "Passed, either format mis-match or issue is resolved!"
        end       
      end
    end
  end
end