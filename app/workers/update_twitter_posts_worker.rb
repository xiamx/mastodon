# frozen_string_literal: true

class UpdateTwitterPostsWorker
  include Sidekiq::Worker

  def perform(tweet_attrs)
    tweet = Twitter::Tweet.new(tweet_attrs)
    CrossSiteTwitter.new.process_tweet!(tweet)
  end
end
