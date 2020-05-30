# frozen_string_literal: true

class Scheduler::SyncCrossSiteFollows
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed, retry: 0

  def perform
    CrossSiteTwitter.new.sync_follows!
  end
end
