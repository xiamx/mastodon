# frozen_string_literal: true

class UpdateTwitterPostsWorker
  include Sidekiq::Worker

  def perform(tweet)
    CrossSiteTwitter.new.process_tweet!(tweet)
  end
end
