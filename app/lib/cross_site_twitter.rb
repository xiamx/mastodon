# frozen_string_literal: true

class CrossSiteTwitter
  def initialize
    twitter_auth = TwitterAuthentication.find_by(system_default: true)
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = twitter_auth.access_token
      config.access_token_secret = twitter_auth.access_token_secret
    end
  end

  def follow(twitter_handle)
    @client.follow(twitter_handle)
  end

  def user_exists?(username)
    @client.user?(username)
  end

  def home_timeline(since_id: nil)
    if since_id.nil?
      @client.home_timeline(tweet_mode: 'extended', count: 200)
    else
      @client.home_timeline(since_id: since_id, tweet_mode: 'extended', count: 200)
    end
  end

  def update!
    home_timeline(since_id: Tweet.order('created_at desc').limit(1).first&.tweet_id).reverse_each do |tweet|
      process_tweet!(tweet)
    end
  end

  def sync_follows!
    owner = TwitterAuthentication.find_by(system_default: true).account.user
    @client.following.each do |twitter_user|
      CrossSiteSubscription.transaction(requires_new: true) do
        CrossSiteSubscription.where(site: 'twitter', foreign_user_id: twitter_user.screen_name.downcase).first_or_create!(
          site: 'twitter', foreign_user_id: twitter_user.screen_name, created_by: owner
        )
      end
    end
  end

  def create_account_if_not_exist(cross_site_subscription)
    twitter_user = @client.user(cross_site_subscription.foreign_user_id)

    CrossSiteAccountCreator.new(cross_site_subscription,
                                display_name: twitter_user.name || twitter_user.screen_name,
                                description: "Mirrored twitter user. not #{twitter_user.screen_name} themself. #{twitter_user.description.presence}",
                                banner_uri: twitter_user.profile_banner_uri? ? twitter_user.profile_banner_uri_https : nil,
                                avatar_uri: twitter_user.profile_image_uri? ? twitter_user.profile_image_uri_https : nil).create_if_not_exist
  end

  def process_tweet!(tweet)
    cross_site_subscription = CrossSiteSubscription.find_by(site: 'twitter', foreign_user_id: tweet.user.screen_name.downcase)
    if cross_site_subscription.present? && cross_site_subscription.account.present?
      tweet_db_obj = persist_or_find_tweet!(tweet, cross_site_subscription.account)
      publish_tweet!(tweet_db_obj)
    end
  end

  private

  def persist_or_find_tweet!(tweet, account)
    tweet_db_obj = Tweet.find_by(tweet_id: tweet.id)
    return tweet_db_obj if tweet_db_obj.present?

    Tweet.create!(tweet_id: tweet.id, full_text: tweet.full_text, account: account, payload: tweet.to_json)
  end

  def publish_tweet!(tweet_db_obj)
    return if tweet_db_obj.published?

    account = tweet_db_obj.account

    media_attachments = process_attachments(tweet_db_obj)
    PostStatusService.new.call(account, text: tweet_db_obj.full_text, media_ids: media_attachments.map(&:id))
    ActivityTracker.record('activity:logins', account.user.id) if account.user.present?
    tweet_db_obj.publish!
  end

  def process_attachments(tweet_db_obj)
    account = tweet_db_obj.account
    payload = ActiveSupport::JSON.decode(tweet_db_obj.payload)
    media_array = payload['entities']['media']
    return [] if media_array.blank?

    media_attachments = []

    media_array.each do |media|
      next if media['media_url'].blank? || media_attachments.size >= 4

      begin
        href             = Addressable::URI.parse(media['media_url']).normalize.to_s
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
end
