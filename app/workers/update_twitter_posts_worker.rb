# frozen_string_literal: true

class UpdateTwitterPostsWorker
  include Sidekiq::Worker
  sidekiq_options retry: 0

  def perform(tweet_attrs)
    tweet = Twitter::Tweet.new(tweet_attrs)
    CrossSiteTwitter.new.process_tweet!(tweet)
  end
end
