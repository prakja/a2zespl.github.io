ActiveAdmin.register DoubtChatDoubt do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :doubt_chat_user_id, :doubt_chat_channel_id, :content, :upvote_count, :downvote_count, :deleted, :doubt_answers_count, :accepted_doubt_answer_id, :cached_votes_total, :cached_votes_score, :cached_votes_up, :cached_votes_down, :cached_weighted_score, :cached_weighted_total, :cached_weighted_average
  remove_filter :user, :channel, :answers
  #
  # or
  #
  # permit_params do
  #   permitted = [:doubt_chat_user_id, :doubt_chat_channel_id, :content, :upvote_count, :downvote_count, :deleted, :doubt_answers_count, :accepted_doubt_answer_id, :cached_votes_total, :cached_votes_score, :cached_votes_up, :cached_votes_down, :cached_weighted_score, :cached_weighted_total, :cached_weighted_average]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Doubt Chat Doubt" do
      f.input :channel
      f.input :content
      f.input :deleted
    end
    f.actions
  end

  controller do
    def most_voted
      # render html: '<div>html goes here</div>'.html_safe
      @start = params[:start]
      if @start.blank?
        @start = 10.year.ago.strftime("%F")
        redirect_to "/admin/top_voted_doubt?start=" + @start
        return
      end
      @end = params[:end]
      if @end.blank?
        @end = Time.now.strftime("%F")
        redirect_to "/admin/top_voted_doubt?start=" + @start + "&end=" + @end
        return
      end
      @phy_doubt = DoubtChatDoubt.joins(:channel).where('"doubt_chat_channels"."name" like \'Phy%\'').where(created_at: @start..@end).order(upvote_count: :DESC).first
      @chem_doubt = DoubtChatDoubt.joins(:channel).where('"doubt_chat_channels"."name" like \'Chem%\'').where(created_at: @start..@end).order(upvote_count: :DESC).first
      @bio_doubt = DoubtChatDoubt.joins(:channel).where('"doubt_chat_channels"."name" like \'Bio%\'').where(created_at: @start..@end).order(upvote_count: :DESC).first
    end
  end

  action_item :most_voted_doubts, only: :index do
    link_to 'Top Voted Doubt', '/admin/top_voted_doubt'
  end
  
end
