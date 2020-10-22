class CrossSiteGeneric
  def initialize(site)
    @site = site
    @rss_bridge_host = ENV['RSS_BRIDGE_URL']

  end

  def update_all!
    CrossSiteSubscription.where(site: @site).find_each do |sub|
      UpdateRssPostsWorker.perform_async @site, sub.id
    end
  end

  def update!(subscription)
    account = create_account_if_not_exist(subscription)
    feed_items(subscription.foreign_user_id).reverse_each do |post|
      process_post post, account
    end
  end

  def create_account_if_not_exist(subscription)
    fg = feed_generics(subscription.foreign_user_id)
    creator = CrossSiteAccountCreator.new(subscription)
    account = creator.current_account
    if account.blank?
      creator = CrossSiteAccountCreator.new(
          subscription, {
          display_name: fg[:name],
          description: fg[:link]
      })
      account = creator.create_if_not_exist
    end

    account
  end

  def feed_generics(foreign_user_id)
    f = feed(foreign_user_id)
    {
        name: f.title,
        link: f.url
    }
  end

  private

  def process_post(post, account)
    post_obj = persist_or_find_post!(post, account)
    publish_post!(post_obj)
  end

  def publish_post!(post_db_obj)
    return if post_db_obj.published?

    account = post_db_obj.account

    media_attachments = process_attachments(post_db_obj)
    PostStatusService.new.call(account, text: post_db_obj.full_text, media_ids: media_attachments.map(&:id), visibility: "unlisted")
    ActivityTracker.record('activity:logins', account.user.id)
    post_db_obj.publish!
  end

  def process_attachments(post_db_obj)
    account = post_db_obj.account
    payload = ActiveSupport::JSON.decode(post_db_obj.payload)
    p = Nokogiri::HTML.parse(payload["summary"])
    image_array = p.css('img').map do |i|
      i[:src]
    end
    video_array = []
    return [] if image_array.blank?

    media_attachments = []

    media_array = if !video_array.empty?
                    [video_array.first]
                  else
                    image_array
                  end

    media_array.each do |media|
      next if media_attachments.size >= 4

      href = Addressable::URI.parse(media).normalize.to_s
      media_attachment = MediaAttachment.create(account: account, remote_url: href)
      media_attachment.download_file!
      media_attachments << media_attachment

      media_attachment.save!
    end

    media_attachments
  rescue Addressable::URI::InvalidURIError => e
    Rails.logger.debug "Invalid URL in attachment: #{e}"
    media_attachments
  end

  def persist_or_find_post!(post, account)
    full_text = "#{post.title} #{post.url}"
    post_db_obj = RssPost.find_by(post_id: post.id)
    return post_db_obj if post_db_obj.present?

    RssPost.create!(post_id: post.id, full_text: full_text, account: account, payload: ActiveSupport::JSON.encode(post.to_h))
  end

  def url(foreign_user_id)
    case @site
    when 'instagram'
      "#{@rss_bridge_host}/picuki/profile/#{foreign_user_id}"
    when 'bilibili'
      "#{@rss_bridge_host}/bilibili/user/dynamic/#{foreign_user_id}/disableEmbed=1"
    end
  end

  def feed(foreign_user_id)
    xml = Faraday.get(url(foreign_user_id)).body
    Feedjira.parse(xml)
  end

  def feed_items(foreign_user_id)
    feed(foreign_user_id).entries
  end
end
