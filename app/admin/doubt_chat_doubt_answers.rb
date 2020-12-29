ActiveAdmin.register DoubtChatDoubtAnswer do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :doubt_chat_user_id, :doubt_chat_doubt_id, :content, :ancestry, :upvote_count, :downvote_count, :deleted, :display_parent_id, :display_parent_position, :children_count, :accepted_answer, :cached_votes_total, :cached_votes_score, :cached_votes_up, :cached_votes_down, :cached_weighted_score, :cached_weighted_total, :cached_weighted_average
  remove_filter :user, :doubts
  #
  # or
  #
  # permit_params do
  #   permitted = [:doubt_chat_user_id, :doubt_chat_doubt_id, :content, :ancestry, :upvote_count, :downvote_count, :deleted, :display_parent_id, :display_parent_position, :children_count, :accepted_answer, :cached_votes_total, :cached_votes_score, :cached_votes_up, :cached_votes_down, :cached_weighted_score, :cached_weighted_total, :cached_weighted_average]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
