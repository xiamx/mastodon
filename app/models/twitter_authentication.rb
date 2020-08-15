# == Schema Information
#
# Table name: twitter_authentications
#
#  id                  :bigint(8)        not null, primary key
#  access_token        :string
#  access_token_secret :string
#  system_default      :boolean
#  account_id          :bigint(8)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class TwitterAuthentication < ApplicationRecord
  validates :access_token, presence: true, uniqueness: true
  validates :access_token_secret, presence: true, uniqueness: true
  belongs_to :account
end
