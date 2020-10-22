# frozen_string_literal: true

class UpdateRssPostsWorker
  include Sidekiq::Worker

  def perform(site, subscription_id)
    CrossSiteGeneric.new(site).update!(CrossSiteSubscription.find(subscription_id))
  end
end
