# frozen_string_literal: true

class UpdateInstagramPostsWorker
  include Sidekiq::Worker

  def perform(subscription_id)
    CrossSiteInstagram.new.update! CrossSiteSubscription.find(subscription_id)
  end
end
