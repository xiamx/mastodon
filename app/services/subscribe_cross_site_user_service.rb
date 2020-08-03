# frozen_string_literal: true

class SubscribeCrossSiteUserService < BaseService
  def call(cross_site_subscription, source_account)
    if cross_site_subscription.site == 'twitter'
      cross_site_twitter = CrossSiteTwitter.new
      cross_site_twitter.follow(cross_site_subscription.foreign_user_id)
      target_account = cross_site_twitter.create_account_if_not_exist(cross_site_subscription.foreign_user_id)
      FollowService.new.call(source_account, target_account)
    end
  end
end
