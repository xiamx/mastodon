# frozen_string_literal: true

class SubscribeCrossSiteUserService < BaseService
  def call(cross_site_subscription, source_account)
    case cross_site_subscription.site
    when 'twitter'
      cross_site_twitter = CrossSiteTwitter.new
      cross_site_twitter.follow(cross_site_subscription.foreign_user_id)
      target_account = cross_site_twitter.create_account_if_not_exist(cross_site_subscription.foreign_user_id)
      FollowService.new.call(source_account, target_account)
    when 'instagram'
      cross_site_instagram = CrossSiteInstagram.new
      target_account = cross_site_instagram.create_account_if_not_exist(cross_site_subscription.foreign_user_id)
      FollowService.new.call(source_account, target_account)
      UpdateInstagramPostsWorker.perform_async(cross_site_subscription.normalized_account_username)
    end
  end
end
