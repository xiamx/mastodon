# == Schema Information
#
# Table name: tweets
#
#  id           :bigint(8)        not null, primary key
#  tweet_id     :bigint(8)        not null
#  account_id   :bigint(8)
#  full_text    :string
#  payload      :jsonb
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  published_at :datetime
#
class Tweet < ApplicationRecord
  belongs_to :account

  scope :unpublished, -> { where("published_at is not null") }

  def publish!
    self.published_at = Time.now.utc
    self.save!
  end

  def published?
    ! self.published_at.nil?
  end
end
