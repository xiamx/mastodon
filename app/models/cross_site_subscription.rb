# == Schema Information
#
# Table name: cross_site_subscriptions
#
#  id              :bigint(8)        not null, primary key
#  site            :string
#  foreign_user_id :string
#  state           :string
#  user_id         :bigint(8)        not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class CrossSiteSubscription < ApplicationRecord
  belongs_to :user
end
