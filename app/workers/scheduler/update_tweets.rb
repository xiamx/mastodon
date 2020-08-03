# frozen_string_literal: true

class Scheduler::UpdateTweets
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed, retry: 0

  def perform
    CrossSiteTwitter.new.update!
  end
end
