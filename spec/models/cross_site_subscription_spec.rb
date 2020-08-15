require 'rails_helper'

RSpec.describe CrossSiteSubscription, type: :model do
  context "when adding a new twitter cross site subscription" do
    let(:user) { Fabricate.build(:user) }
    it "succeeds" do
      allow(CrossSiteTwitter).to receive_message_chain(:new, :user_exists?).and_return true
      css = described_class.new(site: 'twitter', foreign_user_id: 'test', created_by: user)
      expect(css.save!).to be_truthy
    end
  end
end
