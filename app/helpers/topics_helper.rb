module TopicsHelper
  def like_topic_tag
    if current_user
      like = "active" if current_user.like_topic? @topic
    end
    like_counts = " #{@topic.like_users.count} 个 赞" if @topic.like_users.present?
    users = user_avatar_tag(@topic.like_users, :xs, link: true)
    content = link_to(raw("<i class='fa fa fa-heart'></i><span>#{like_counts}</span>"), "#",
                      class: " button-heart #{like}", data: { id: @topic.id })
    raw(content_tag("li", content, "data-toggle" => "popover", "data-content" => users.to_s))
  end

  def collect_topic_tag
    if current_user
      collect = "active" if current_user.collect_topic?(@topic)
    end
    content = link_to(raw('<i class="fa fa-bookmark"></i>收藏'), "#",
                      class: "button-collect #{collect}", data: { id: @topic.id })
    raw(content_tag("li", content))
  end

  def place_top_topic_tag
    return nil unless @admin
    content = if @topic.place_top
                link_to raw("<i class='fa fa-angle-double-up'></i> 取消"),
                        action_admin_topic_path(@topic, type: "cancel"), method: :post, remote: true
              else
                link_to raw('<i class="fa fa-angle-double-up"></i>置顶'),
                        action_admin_topic_path(@topic, type: "place_top"), method: :post, remote: true
              end
    raw(content_tag("li", content))
  end

  def excellent_topic_tag
    return nil unless @admin
    return nil if @topic.excellent
    content = link_to raw('<i class="fa fa-diamond"></i>加精'),
                      action_admin_topic_path(@topic, type: "excellent"), method: :post, remote: true
    raw(content_tag("li", content, class: "excell-li"))
  end

  def ban_topic_tag
    return nil unless @admin
    return nil if @topic.ban
    content = link_to raw('<i class="fa fa-ban"></i>屏蔽'),
                      action_admin_topic_path(@topic, type: "ban"), method: :post, remote: true
    raw(content_tag("li", content, class: "ban-li"))
  end

  def discuss_topic_tag
    return nil unless @user || @admin
    content = if @topic.discuss
                link_to raw('<i class="fa fa-check"></i>'),
                        action_admin_topic_path(@topic, type: "close"), method: :post, remote: true
              else
                link_to raw('<i class="fa fa-undo"></i>'),
                        action_admin_topic_path(@topic, type: "open"), method: :post, remote: true
              end
    raw(content_tag("li", content))
  end

  def edit_topic_tag
    content = link_to raw('<i class="fa fa-pencil"></i>'), edit_topic_path(@topic)
    raw(content_tag("li", content))
  end

  def user_admin?
    @admin = current_user && current_user.admin?
  end

  def topic_belong_to_user?
    @user = current_user && current_user.id == @topic.user_id
  end
end
