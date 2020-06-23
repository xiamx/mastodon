# frozen_string_literal: true

class CrossSiteInstagram
  def initialize
    @rss_bridge_host = ENV['RSS_BRIDGE_URL']
  end

  def update_all!
    CrossSiteSubscription.where(site: 'instagram').find_each do |sub|
      UpdateInstagramPostsWorker.perform_async sub.id
    end
  end

  def update!(subscription)
    account = create_account_if_not_exist(subscription)
    feed_items(subscription.foreign_user_id).reverse_each do |post|
      process_instagram_post post, account
    end
  end

  def create_account_if_not_exist(subscription)
    creator = CrossSiteAccountCreator.new(subscription)
    account = creator.current_account
    if account.blank?
      basic_info = fetch_profile_basics(subscription.foreign_user_id)
      creator = CrossSiteAccountCreator.new(
        subscription,
        basic_info
      )
      account = creator.create_if_not_exist
    end

    account
  end

  def fetch_profile_basics(instagram_user_id)
    uri = URI("https://www.instagram.com/web/search/topsearch/?query=#{instagram_user_id}")
    Net::HTTP.start(uri.host, uri.port,
                    use_ssl: uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri, "User-Agent": 'Mozilla/5.0 (X11; Linux i686; rv:77.0) Gecko/20100101 Firefox/77.0'
      response = http.request request # Net::HTTPResponse object
      begin
        document = ActiveSupport::JSON.decode(response.body)
        matching_user = document['users'][0]['user']
        {
          avatar_uri: matching_user['profile_pic_url'],
          display_name: matching_user['full_name'],
        }
      rescue ActiveSupport::JSON.parse_error
        {}
      end
    end
  end

  private

  def process_instagram_post(post, account)
    post_obj = persist_or_find_post!(post, account)
    publish_post!(post_obj)
  end

  def publish_post!(post_db_obj)
    return if post_db_obj.published?

    account = post_db_obj.account

    media_attachments = process_attachments(post_db_obj)
    PostStatusService.new.call(account, text: post_db_obj.full_text, media_ids: media_attachments.map(&:id))
    post_db_obj.publish!
  end

  def process_attachments(post_db_obj)
    account = post_db_obj.account
    payload = ActiveSupport::JSON.decode(post_db_obj.payload)
    media_array = payload['attachments']
    return [] if media_array.blank?

    media_attachments = []

    video_array = media_array.select { |media| media['mime_type'] == 'video/mp4' }
    image_array = media_array.select { |media| media['mime_type'] == 'image/jpeg' }

    media_array = if !video_array.empty?
                    [video_array.first]
                  else
                    image_array
                  end

    media_array.each do |media|
      next if media['url'].blank? || media_attachments.size >= 4

      begin
        href             = Addressable::URI.parse(media['url']).normalize.to_s
        media_attachment = MediaAttachment.create(account: account, remote_url: href)
        media_attachments << media_attachment

        media_attachment.file_remote_url = href
        media_attachment.save
      rescue Mastodon::UnexpectedResponseError, HTTP::TimeoutError, HTTP::ConnectionError, OpenSSL::SSL::SSLError
        RedownloadMediaWorker.perform_in(rand(30..600).seconds, media_attachment.id)
      end
    end

    media_attachments
  rescue Addressable::URI::InvalidURIError => e
    Rails.logger.debug "Invalid URL in attachment: #{e}"
    media_attachments
  end

  def persist_or_find_post!(post, account)
    full_text = if post['title'].present?
                  "#{post['title']} #{post['url']}"
                else
                  post['url']
                end
    post_db_obj = InstagramPost.find_by(post_id: post['id'])
    return post_db_obj if post_db_obj.present?

    InstagramPost.create!(post_id: post['id'], full_text: full_text, account: account, payload: JSON.dump(post))
  end

  def feed_items(instagram_user_id)
    JSON.parse(
      Net::HTTP.get(
        URI.parse(@rss_bridge_host + "/?action=display&bridge=Instagram&context=Username&u=#{instagram_user_id}&media_type=all&format=Json")
      )
    )['items']
  end
end
