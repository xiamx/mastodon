class CrossSiteSubSensitive < ActiveRecord::Migration[5.2]
  def change
    add_column :cross_site_subscriptions, :sensitive, :boolean
  end
end
