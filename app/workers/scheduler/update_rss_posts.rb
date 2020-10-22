# frozen_string_literal: true

class Scheduler::UpdateRssPosts
  include Sidekiq::Worker

  def perform
    CrossSiteGeneric.new('instagram').update_all!
    CrossSiteGeneric.new('bilibili').update_all!
  end
end
