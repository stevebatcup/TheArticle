# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_03_04_093300) do

  create_table "account_deletions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.string "reason"
    t.boolean "by_admin"
    t.datetime "created_at"
  end

  create_table "additional_emails", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "api_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.string "service"
    t.integer "user_id"
    t.string "request_type"
    t.string "request_method"
    t.text "request_data", limit: 4294967295
    t.text "response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["request_method"], name: "index_api_logs_on_request_method"
    t.index ["service"], name: "index_api_logs_on_service"
    t.index ["user_id"], name: "index_api_logs_on_user_id"
  end

  create_table "articles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.integer "wp_id"
    t.string "title"
    t.integer "author_id"
    t.integer "additional_author_id"
    t.text "content", limit: 4294967295
    t.string "image"
    t.string "image_caption"
    t.integer "wp_image_id"
    t.string "slug"
    t.string "remote_article_url", limit: 1000
    t.string "remote_article_domain"
    t.text "remote_article_image_url"
    t.text "excerpt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "published_at"
    t.string "canonical_url"
    t.text "page_title"
    t.text "meta_description"
    t.string "social_image"
    t.boolean "robots_nofollow"
    t.boolean "robots_noindex"
    t.boolean "is_sponsored", default: false
    t.integer "ratings_well_written_cache"
    t.integer "ratings_valid_points_cache"
    t.integer "ratings_agree_cache"
    t.text "meta_keywords"
    t.text "meta_entities"
    t.text "meta_concepts"
    t.boolean "has_bibblio_meta", default: false
    t.index ["meta_concepts"], name: "index_articles_on_meta_concepts", type: :fulltext
    t.index ["meta_entities"], name: "index_articles_on_meta_entities", type: :fulltext
    t.index ["meta_keywords"], name: "index_articles_on_meta_keywords", type: :fulltext
  end

  create_table "articles_exchanges", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "article_id"
    t.bigint "exchange_id"
    t.datetime "created_at"
    t.index ["article_id"], name: "index_articles_exchanges_on_article_id"
    t.index ["exchange_id"], name: "index_articles_exchanges_on_exchange_id"
  end

  create_table "articles_keyword_tags", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "article_id"
    t.bigint "keyword_tag_id"
    t.index ["article_id"], name: "index_articles_keyword_tags_on_article_id"
    t.index ["keyword_tag_id"], name: "index_articles_keyword_tags_on_keyword_tag_id"
  end

  create_table "author_images", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "wp_id"
    t.integer "author_id"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "author_roles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "authors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "wp_id"
    t.string "display_name"
    t.string "role_id"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "slug"
    t.string "image"
    t.integer "wp_image_id"
    t.string "url"
    t.string "title"
    t.text "blurb"
    t.string "twitter_handle"
    t.string "facebook_url"
    t.string "instagram_username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "article_count"
    t.string "youtube_url"
    t.boolean "on_mailchimp_list", default: false
  end

  create_table "black_list_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.string "email"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "added_by_admin_user_id"
  end

  create_table "blocks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.integer "blocked_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blocked_id"], name: "index_blocks_on_blocked_id"
    t.index ["user_id"], name: "index_blocks_on_user_id"
  end

  create_table "chats", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "last_message_id"
    t.integer "message_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "commentable_id"
    t.string "commentable_type"
    t.string "title"
    t.text "body"
    t.string "subject"
    t.integer "user_id", null: false
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "communication_preferences", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.string "preference"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "concern_reports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "reporter_id"
    t.integer "reported_id"
    t.integer "status", default: 0
    t.string "primary_reason"
    t.string "secondary_reason"
    t.text "more_info"
    t.integer "sourceable_id"
    t.string "sourceable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reported_id"], name: "index_concern_reports_on_reported_id"
    t.index ["reporter_id"], name: "index_concern_reports_on_reporter_id"
    t.index ["sourceable_type", "sourceable_id"], name: "index_concern_reports_on_sourceable_type_and_sourceable_id"
  end

  create_table "conversers", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "chat_id"
    t.bigint "user_id"
    t.boolean "is_chat_initiator"
    t.index ["chat_id"], name: "index_conversers_on_chat_id"
    t.index ["user_id"], name: "index_conversers_on_user_id"
  end

  create_table "daily_user_mail_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.string "action_type"
    t.integer "action_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_daily_user_mail_items_on_created_at"
    t.index ["user_id"], name: "index_daily_user_mail_items_on_user_id"
  end

  create_table "email_alias_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.string "old_email"
    t.string "new_email"
    t.text "reason"
    t.string "old_username"
    t.string "new_username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exchange_mutes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.integer "muted_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exchanges", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "wp_id"
    t.string "name"
    t.string "slug"
    t.text "description"
    t.string "image"
    t.integer "wp_image_id"
    t.boolean "is_trending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "article_count", default: 0
    t.integer "follower_count", default: 0
  end

  create_table "exchanges_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "exchange_id"
    t.bigint "user_id"
    t.datetime "created_at"
    t.index ["exchange_id"], name: "index_exchanges_users_on_exchange_id"
    t.index ["user_id"], name: "index_exchanges_users_on_user_id"
  end

  create_table "feed_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.string "action_type"
    t.integer "source_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_id"], name: "index_feed_users_on_source_id"
    t.index ["user_id", "source_id"], name: "index_feed_users_on_user_id_and_source_id"
    t.index ["user_id"], name: "index_feed_users_on_user_id"
  end

  create_table "feed_users_feeds", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "feed_user_id"
    t.bigint "feed_id"
    t.index ["feed_id"], name: "index_feed_users_feeds_on_feed_id"
    t.index ["feed_user_id", "feed_id"], name: "index_feed_users_feeds_on_feed_user_id_and_feed_id"
    t.index ["feed_user_id"], name: "index_feed_users_feeds_on_feed_user_id"
  end

  create_table "feedback_submissions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "name"
    t.text "url"
    t.string "platform"
    t.string "browser"
    t.string "device"
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "feeds", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "user_id"
    t.integer "actionable_id"
    t.string "actionable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actionable_type", "actionable_id"], name: "index_feeds_on_actionable_type_and_actionable_id"
    t.index ["user_id", "actionable_type", "actionable_id"], name: "index_feeds_on_user_id_and_actionable_type_and_actionable_id"
    t.index ["user_id"], name: "index_feeds_on_user_id"
  end

  create_table "feeds_notifications", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "feed_id"
    t.bigint "notification_id"
    t.index ["feed_id"], name: "index_feeds_notifications_on_feed_id"
    t.index ["notification_id", "feed_id"], name: "index_feeds_notifications_on_notification_id_and_feed_id"
    t.index ["notification_id"], name: "index_feeds_notifications_on_notification_id"
  end

  create_table "follow_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "follow_mutes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.integer "muted_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "follows", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.integer "followed_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "follow_group_id"
    t.index ["followed_id"], name: "index_follows_on_followed_id"
    t.index ["user_id"], name: "index_follows_on_user_id"
  end

  create_table "future_articles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "wp_id"
    t.datetime "publish_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "help_contents", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "help_section_id"
    t.text "question"
    t.text "answer"
    t.integer "sort"
    t.integer "top_question_sort"
  end

  create_table "help_feedbacks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "question_id"
    t.string "outcome"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "help_sections", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "title"
    t.integer "sort"
  end

  create_table "interaction_mutes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.integer "share_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "keyword_tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "wp_id"
    t.string "name"
    t.string "slug"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "article_count", default: 0
  end

  create_table "keyword_tags_landing_pages", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "keyword_tag_id"
    t.bigint "landing_page_id"
    t.index ["keyword_tag_id"], name: "index_keyword_tags_landing_pages_on_keyword_tag_id"
    t.index ["landing_page_id"], name: "index_keyword_tags_landing_pages_on_landing_page_id"
  end

  create_table "landing_pages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "heading"
    t.string "slug"
    t.text "intro"
    t.string "articles_heading"
    t.boolean "show_home_link", default: false
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "linked_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.integer "linked_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "chat_id"
    t.bigint "user_id"
    t.text "body"
    t.boolean "is_ice_breaker", default: false
    t.datetime "read_by_recipient_at"
    t.index ["chat_id"], name: "index_messages_on_chat_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "mutes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.integer "muted_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["muted_id"], name: "index_mutes_on_muted_id"
    t.index ["user_id"], name: "index_mutes_on_user_id"
  end

  create_table "notification_settings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.string "key"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "eventable_id"
    t.string "eventable_type"
    t.string "specific_type"
    t.integer "share_id"
    t.integer "feed_id"
    t.text "body", limit: 4294967295
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_new"
    t.boolean "is_seen"
    t.index ["eventable_type", "eventable_id"], name: "index_notifications_on_eventable_type_and_eventable_id"
    t.index ["is_new"], name: "index_notifications_on_is_new"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "opinion_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.integer "share_id"
    t.text "body"
    t.string "decision"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "opinions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.integer "share_id"
    t.string "decision"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "opinion_group_id"
    t.index ["share_id"], name: "index_opinions_on_share_id"
    t.index ["user_id", "share_id", "decision"], name: "index_opinions_on_user_id_and_share_id_and_decision"
    t.index ["user_id"], name: "index_opinions_on_user_id"
  end

  create_table "pages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "wp_id"
    t.string "title"
    t.text "content"
    t.string "slug"
    t.text "meta_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pending_follows", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.integer "followed_id"
    t.integer "follow_id"
  end

  create_table "profile_suggestion_archives", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.integer "suggested_id"
    t.integer "reason_for_archive"
    t.datetime "created_at"
    t.index ["reason_for_archive"], name: "index_profile_suggestion_archives_on_reason_for_archive"
    t.index ["suggested_id"], name: "index_profile_suggestion_archives_on_suggested_id"
    t.index ["user_id"], name: "index_profile_suggestion_archives_on_user_id"
  end

  create_table "profile_suggestions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.integer "suggested_id"
    t.string "reason"
    t.integer "author_article_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_article_count"], name: "index_profile_suggestions_on_author_article_count"
    t.index ["reason"], name: "index_profile_suggestions_on_reason", type: :fulltext
    t.index ["user_id"], name: "index_profile_suggestions_on_user_id"
  end

  create_table "push_tokens", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.string "token"
    t.string "browser"
    t.string "device"
    t.datetime "created_at"
  end

  create_table "quarantined_third_party_shares", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "url"
    t.integer "status"
    t.integer "article_id"
    t.string "heading"
    t.text "snippet", limit: 4294967295
    t.text "post"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image", limit: 1000
    t.integer "rating_well_written", default: 0
    t.integer "rating_valid_points", default: 0
    t.integer "rating_agree", default: 0
    t.integer "handled_by_admin_user_id"
  end

  create_table "search_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.string "term"
    t.string "full_article_term"
    t.integer "all_results_count", default: 0
    t.integer "articles_results_count", default: 0
    t.integer "contributors_results_count", default: 0
    t.integer "profiles_results_count", default: 0
    t.integer "exchanges_results_count", default: 0
    t.integer "posts_results_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["term"], name: "index_search_logs_on_term"
    t.index ["user_id"], name: "index_search_logs_on_user_id"
  end

  create_table "shares", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "share_type", default: "rating"
    t.integer "user_id"
    t.integer "article_id"
    t.text "post"
    t.integer "rating_well_written"
    t.integer "rating_valid_points"
    t.integer "rating_agree"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_shares_on_article_id"
    t.index ["user_id"], name: "index_shares_on_user_id"
  end

  create_table "third_party_share_error_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.text "url"
    t.integer "user_id"
    t.string "error_show_to_user"
    t.text "exception_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_admin_notes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.integer "admin_user_id"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "status", default: 0
    t.string "title"
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.integer "admin_level", default: 0
    t.string "slug"
    t.boolean "has_completed_wizard", default: false
    t.string "username", default: ""
    t.string "display_name", default: ""
    t.boolean "verified_as_genuine", default: false
    t.string "gender"
    t.string "age_bracket"
    t.string "location", default: ""
    t.string "private_location"
    t.decimal "lat", precision: 10, scale: 7
    t.decimal "lng", precision: 10, scale: 7
    t.string "country_code"
    t.string "profile_photo"
    t.integer "default_profile_photo_id"
    t.string "cover_photo"
    t.text "bio"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "signup_ip_address"
    t.string "signup_ip_city"
    t.string "signup_ip_region"
    t.string "signup_ip_country"
    t.integer "notification_counter_cache"
    t.integer "author_id"
    t.integer "followers_count", default: 0
    t.integer "followings_count", default: 0
    t.integer "connections_count", default: 0
    t.integer "share_all_count", default: 0
    t.integer "share_ratings_count", default: 0
    t.boolean "on_bibblio", default: false
    t.string "registration_source", default: "website"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug"
  end

  create_table "watch_list_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.integer "status", default: 0
    t.integer "reason", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "added_by_admin_user_id"
  end

  create_table "weekly_user_mail_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "user_id"
    t.string "action_type"
    t.integer "action_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_weekly_user_mail_items_on_created_at"
    t.index ["user_id"], name: "index_weekly_user_mail_items_on_user_id"
  end

  create_table "white_listed_third_party_publishers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.string "name"
    t.string "domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "articles_exchanges", "articles"
  add_foreign_key "articles_exchanges", "exchanges"
  add_foreign_key "articles_keyword_tags", "articles"
  add_foreign_key "articles_keyword_tags", "keyword_tags"
  add_foreign_key "conversers", "chats"
  add_foreign_key "conversers", "users"
  add_foreign_key "exchanges_users", "exchanges"
  add_foreign_key "exchanges_users", "users"
  add_foreign_key "feed_users_feeds", "feed_users"
  add_foreign_key "feed_users_feeds", "feeds"
  add_foreign_key "feeds_notifications", "feeds"
  add_foreign_key "feeds_notifications", "notifications"
  add_foreign_key "keyword_tags_landing_pages", "keyword_tags"
  add_foreign_key "keyword_tags_landing_pages", "landing_pages"
end
