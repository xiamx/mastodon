class RemoveUnusedIndexes20200608 < ActiveRecord::Migration[5.2]
  def change
    remove_index :media_attachments, name: "index_media_attachments_on_scheduled_status_id"
    remove_index :accounts, name: "index_accounts_on_url"
    remove_index :account_conversations, name: "index_account_conversations_on_conversation_id"
    remove_index :announcement_mutes, name: "index_announcement_mutes_on_announcement_id"
    remove_index :cross_site_subscriptions, name: "index_cross_site_subscriptions_on_user_id"
    remove_index :favourites, name: "index_favourites_on_account_id_and_id"
    remove_index :users, name: "index_users_on_created_by_application_id"
    remove_index :announcement_reactions, name: "index_announcement_reactions_on_custom_emoji_id"
    remove_index :list_accounts, name: "index_list_accounts_on_list_id_and_account_id"
    remove_index :scheduled_statuses, name: "index_scheduled_statuses_on_scheduled_at"
  end
end
