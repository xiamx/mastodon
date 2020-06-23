# frozen_string_literal: true

class UpdateInstagramPostsWorker
  include Sidekiq::Worker

  def perform(subscription)
    CrossSiteInstagram.new.update! subscription
  end
end
