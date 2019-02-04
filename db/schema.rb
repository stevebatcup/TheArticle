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

ActiveRecord::Schema.define(version: 2019_02_04_110706) do

  create_table "articles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "wp_id"
    t.string "title"
    t.integer "author_id"
    t.text "content"
    t.string "image"
    t.string "image_caption"
    t.integer "wp_image_id"
    t.string "slug"
    t.string "remote_article_url", limit: 1000
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
  end

  create_table "articles_exchanges", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "article_id"
    t.bigint "exchange_id"
    t.datetime "created_at"
    t.index ["article_id"], name: "index_articles_exchanges_on_article_id"
    t.index ["exchange_id"], name: "index_articles_exchanges_on_exchange_id"
  end

  create_table "articles_keyword_tags", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "article_id"
    t.bigint "keyword_tag_id"
    t.index ["article_id"], name: "index_articles_keyword_tags_on_article_id"
    t.index ["keyword_tag_id"], name: "index_articles_keyword_tags_on_keyword_tag_id"
  end

  create_table "author_roles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "authors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
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
  end

  create_table "black_list_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blocks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "blocked_id"
    t.string "status"
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

  create_table "communication_preferences", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "preference"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "concern_reports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
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

  create_table "email_alias_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "old_email"
    t.string "new_email"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exchanges", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
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
  end

  create_table "exchanges_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "exchange_id"
    t.bigint "user_id"
    t.datetime "created_at"
    t.index ["exchange_id"], name: "index_exchanges_users_on_exchange_id"
    t.index ["user_id"], name: "index_exchanges_users_on_user_id"
  end

  create_table "feeds", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "user_id"
    t.integer "actionable_id"
    t.string "actionable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actionable_type", "actionable_id"], name: "index_feeds_on_actionable_type_and_actionable_id"
    t.index ["user_id", "actionable_type", "actionable_id"], name: "index_feeds_on_user_id_and_actionable_type_and_actionable_id"
    t.index ["user_id"], name: "index_feeds_on_user_id"
  end

  create_table "follow_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "follows", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "followed_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "follow_group_id"
  end

  create_table "keyword_tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "wp_id"
    t.string "name"
    t.string "slug"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mutes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "muted_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notification_settings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "key"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "eventable_id"
    t.string "eventable_type"
    t.string "specific_type"
    t.integer "feed_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_new"
    t.boolean "is_seen"
    t.index ["eventable_type", "eventable_id"], name: "index_notifications_on_eventable_type_and_eventable_id"
    t.index ["is_new"], name: "index_notifications_on_is_new"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "opinion_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "share_id"
    t.text "body"
    t.string "decision"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "opinions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "share_id"
    t.string "decision"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "opinion_group_id"
  end

  create_table "pages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "wp_id"
    t.string "title"
    t.text "content"
    t.string "slug"
    t.text "meta_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profile_suggestions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "suggested_id"
    t.string "reason"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "quarantined_third_party_shares", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "url"
    t.integer "status"
    t.integer "article_id"
    t.string "heading"
    t.text "snippet"
    t.text "post"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image", limit: 1000
    t.integer "rating_well_written", default: 0
    t.integer "rating_valid_points", default: 0
    t.integer "rating_agree", default: 0
  end

  create_table "search_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "term"
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

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "status", default: 0
    t.string "title"
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.integer "admin_level", default: 0
    t.string "slug"
    t.boolean "has_completed_wizard", default: false
    t.string "username", default: ""
    t.string "display_name", default: ""
    t.string "location", default: ""
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
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug"
  end

  create_table "watch_list_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "white_listed_third_party_publishers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wp_commentmeta", primary_key: "meta_id", id: :bigint, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.bigint "comment_id", default: 0, null: false, unsigned: true
    t.string "meta_key"
    t.text "meta_value", limit: 4294967295
    t.index ["comment_id"], name: "comment_id"
    t.index ["meta_key"], name: "meta_key", length: 191
  end

  create_table "wp_comments", primary_key: "comment_ID", id: :bigint, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.bigint "comment_post_ID", default: 0, null: false, unsigned: true
    t.text "comment_author", limit: 255, null: false
    t.string "comment_author_email", limit: 100, default: "", null: false
    t.string "comment_author_url", limit: 200, default: "", null: false
    t.string "comment_author_IP", limit: 100, default: "", null: false
    t.datetime "comment_date", null: false
    t.datetime "comment_date_gmt", null: false
    t.text "comment_content", null: false
    t.integer "comment_karma", default: 0, null: false
    t.string "comment_approved", limit: 20, default: "1", null: false
    t.string "comment_agent", default: "", null: false
    t.string "comment_type", limit: 20, default: "", null: false
    t.bigint "comment_parent", default: 0, null: false, unsigned: true
    t.bigint "user_id", default: 0, null: false, unsigned: true
    t.index ["comment_approved", "comment_date_gmt"], name: "comment_approved_date_gmt"
    t.index ["comment_author_email"], name: "comment_author_email", length: 10
    t.index ["comment_date_gmt"], name: "comment_date_gmt"
    t.index ["comment_parent"], name: "comment_parent"
    t.index ["comment_post_ID"], name: "comment_post_ID"
  end

  create_table "wp_earlyRegistrants", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "first_name", limit: 99
    t.string "last_name", limit: 99
    t.string "email", limit: 199
    t.datetime "created_at"
  end

  create_table "wp_links", primary_key: "link_id", id: :bigint, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.string "link_url", default: "", null: false
    t.string "link_name", default: "", null: false
    t.string "link_image", default: "", null: false
    t.string "link_target", limit: 25, default: "", null: false
    t.string "link_description", default: "", null: false
    t.string "link_visible", limit: 20, default: "Y", null: false
    t.bigint "link_owner", default: 1, null: false, unsigned: true
    t.integer "link_rating", default: 0, null: false
    t.datetime "link_updated", null: false
    t.string "link_rel", default: "", null: false
    t.text "link_notes", limit: 16777215, null: false
    t.string "link_rss", default: "", null: false
    t.index ["link_visible"], name: "link_visible"
  end

  create_table "wp_options", primary_key: "option_id", id: :bigint, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.string "option_name", limit: 191, default: "", null: false
    t.text "option_value", limit: 4294967295, null: false
    t.string "autoload", limit: 20, default: "yes", null: false
    t.index ["option_name"], name: "option_name", unique: true
  end

  create_table "wp_postmeta", primary_key: "meta_id", id: :bigint, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.bigint "post_id", default: 0, null: false, unsigned: true
    t.string "meta_key"
    t.text "meta_value", limit: 4294967295
    t.index ["meta_key"], name: "meta_key", length: 191
    t.index ["post_id"], name: "post_id"
  end

  create_table "wp_posts", primary_key: "ID", id: :bigint, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.bigint "post_author", default: 0, null: false, unsigned: true
    t.datetime "post_date", null: false
    t.datetime "post_date_gmt", null: false
    t.text "post_content", limit: 4294967295, null: false
    t.text "post_title", null: false
    t.text "post_excerpt", null: false
    t.string "post_status", limit: 20, default: "publish", null: false
    t.string "comment_status", limit: 20, default: "open", null: false
    t.string "ping_status", limit: 20, default: "open", null: false
    t.string "post_password", default: "", null: false
    t.string "post_name", limit: 200, default: "", null: false
    t.text "to_ping", null: false
    t.text "pinged", null: false
    t.datetime "post_modified", null: false
    t.datetime "post_modified_gmt", null: false
    t.text "post_content_filtered", limit: 4294967295, null: false
    t.bigint "post_parent", default: 0, null: false, unsigned: true
    t.string "guid", default: "", null: false
    t.integer "menu_order", default: 0, null: false
    t.string "post_type", limit: 20, default: "post", null: false
    t.string "post_mime_type", limit: 100, default: "", null: false
    t.bigint "comment_count", default: 0, null: false
    t.index ["post_author"], name: "post_author"
    t.index ["post_name"], name: "post_name", length: 191
    t.index ["post_parent"], name: "post_parent"
    t.index ["post_type", "post_status", "post_date", "ID"], name: "type_status_date"
  end

  create_table "wp_term_relationships", primary_key: ["object_id", "term_taxonomy_id"], options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.bigint "object_id", default: 0, null: false, unsigned: true
    t.bigint "term_taxonomy_id", default: 0, null: false, unsigned: true
    t.integer "term_order", default: 0, null: false
    t.index ["term_taxonomy_id"], name: "term_taxonomy_id"
  end

  create_table "wp_term_taxonomy", primary_key: "term_taxonomy_id", id: :bigint, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.bigint "term_id", default: 0, null: false, unsigned: true
    t.string "taxonomy", limit: 32, default: "", null: false
    t.text "description", limit: 4294967295, null: false
    t.bigint "parent", default: 0, null: false, unsigned: true
    t.bigint "count", default: 0, null: false
    t.index ["taxonomy"], name: "taxonomy"
    t.index ["term_id", "taxonomy"], name: "term_id_taxonomy", unique: true
  end

  create_table "wp_termmeta", primary_key: "meta_id", id: :bigint, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.bigint "term_id", default: 0, null: false, unsigned: true
    t.string "meta_key"
    t.text "meta_value", limit: 4294967295
    t.index ["meta_key"], name: "meta_key", length: 191
    t.index ["term_id"], name: "term_id"
  end

  create_table "wp_terms", primary_key: "term_id", id: :bigint, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.string "name", limit: 200, default: "", null: false
    t.string "slug", limit: 200, default: "", null: false
    t.bigint "term_group", default: 0, null: false
    t.index ["name"], name: "name", length: 191
    t.index ["slug"], name: "slug", length: 191
  end

  create_table "wp_usermeta", primary_key: "umeta_id", id: :bigint, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.bigint "user_id", default: 0, null: false, unsigned: true
    t.string "meta_key"
    t.text "meta_value", limit: 4294967295
    t.index ["meta_key"], name: "meta_key", length: 191
    t.index ["user_id"], name: "user_id"
  end

  create_table "wp_users", primary_key: "ID", id: :bigint, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.string "user_login", limit: 60, default: "", null: false
    t.string "user_pass", default: "", null: false
    t.string "user_nicename", limit: 50, default: "", null: false
    t.string "user_email", limit: 100, default: "", null: false
    t.string "user_url", limit: 100, default: "", null: false
    t.datetime "user_registered", null: false
    t.string "user_activation_key", default: "", null: false
    t.integer "user_status", default: 0, null: false
    t.string "display_name", limit: 250, default: "", null: false
    t.index ["user_email"], name: "user_email"
    t.index ["user_login"], name: "user_login_key"
    t.index ["user_nicename"], name: "user_nicename"
  end

  add_foreign_key "articles_exchanges", "articles"
  add_foreign_key "articles_exchanges", "exchanges"
  add_foreign_key "articles_keyword_tags", "articles"
  add_foreign_key "articles_keyword_tags", "keyword_tags"
  add_foreign_key "exchanges_users", "exchanges"
  add_foreign_key "exchanges_users", "users"
end
