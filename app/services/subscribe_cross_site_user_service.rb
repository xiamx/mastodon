# frozen_string_literal: true

class SubscribeCrossSiteUserService < BaseService
  def call(cross_site_subscription, source_account)
    case cross_site_subscription.site
    when 'twitter'
      cross_site_twitter = CrossSiteTwitter.new
      cross_site_twitter.follow(cross_site_subscription.foreign_user_id)
      target_account = cross_site_twitter.create_account_if_not_exist(cross_site_subscription)
      FollowService.new.call(source_account, target_account)
    else
      cross_site_generic = CrossSiteGeneric.new(cross_site_subscription.site)
      target_account = cross_site_generic.create_account_if_not_exist(cross_site_subscription)
      FollowService.new.call(source_account, target_account)
      UpdateRssPostsWorker.perform_async(cross_site_subscription.site, cross_site_subscription.id)
    end
  end
end
