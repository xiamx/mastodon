# frozen_string_literal: true

class UpdateRssPostsWorker
  include Sidekiq::Worker
  sidekiq_options retry: 0

  def perform(site, subscription_id)
    CrossSiteGeneric.new(site).update!(CrossSiteSubscription.find(subscription_id))
  end
end
