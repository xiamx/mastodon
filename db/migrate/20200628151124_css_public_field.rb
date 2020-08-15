class CssPublicField < ActiveRecord::Migration[5.2]
  def change
    add_column :cross_site_subscriptions, :public, :boolean
  end
end
