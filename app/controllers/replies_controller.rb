class RepliesController < ApplicationController
  include UsersHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper

  before_action :find_reply, only: %i[like unlike edit update destroy]
  before_action :find_topic, only: %i[edit]

  def create
    @reply = Reply.new(reply_params)
    if params[:reply][:reply_to_id].present?
      reply_user = Reply.find_by(id: params[:reply][:reply_to_id]).user
      @reply.mentioned_user_ids << reply_user.id
    end
    replies_count = @reply.topic.replies.count
    @reply.topic_id = params[:topic_id]
    @reply.user_id = current_user.id
    @reply.topic.replies_count = replies_count + 1

    @reply.floor = "##{replies_count + 1}"
    @msg = if @reply.save
             "回复成功"
           else
             @reply.errors.full_messages.join("<br />")
           end

    @topic = Topic.find_by(id: params[:topic_id])
    @replies_without_action = @topic.replies.order("id asc").without_action.includes(:user)
  end

  def edit; end

  def update
    @reply.body = params[:reply][:body]
    @reply.save
  end

  def destroy
    @reply.deleted_at = Time.now
    @reply.save
    redirect_to topic_path(@reply.topic_id), notice: "回帖删除成功"
  end

  def reply_params
    params.require(:reply).permit(:body, :reply_to_id)
  end

  def like
    current_user.like_reply(@reply)
    render json: {
      data: {
        likeed_users_count: @reply.likeed_users.count,
        likeed_users: user_avatar_tag(@reply.likeed_users, :xs, link: true)
      }
    }
  end

  def unlike
    current_user.unlike_reply(@reply)
    render json: {
      data: {
        likeed_users_count: @reply.likeed_users.count,
        likeed_users: user_avatar_tag(@reply.likeed_users, :xs, link: true)
      }
    }
  end

  private

  def find_reply
    @reply = Reply.find_by(id: params[:id])
  end

  def find_topic
    @topic = Topic.find_by(id: params[:id])
  end
end
