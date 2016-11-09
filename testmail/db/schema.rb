ActiveRecord::Schema.define(version: 20160304000001) do

  create_table "cv_signup_date" force: true do |t|
    t.string   "uid"
    t.integer  "count"
    t.string   "member_type"
    t.datetime "regist_date"
    t.string   "del_flag",   default: "0"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
  create_table "usage_distributions" force: true do |t|
    t.string   "uid"
    t.integer  "lp_id"
    t.integer  "campaign_id"
    t.string   "member_type"
    t.datetime "regist_date"
    t.integer  "result_url_id"
    t.string   "del_flag",   default: "0"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "usage_distributions_cvs" force: true do |t|
    t.string   "uid"
    t.integer  "service_discrimination_id"
    t.datetime "cv_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "auth_types", force: true do |t|
    t.string   "name"
    t.string   "del_flag",   default: "0"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name_ja"
  end

  create_table "batch_files", force: true do |t|
    t.integer  "graph_id",                   null: false
    t.string   "name",                       null: false
    t.boolean  "del_flg",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "batch_jobs", force: true do |t|
    t.integer  "graph_id",                        null: false
    t.integer  "status2_type_id",                 null: false
    t.boolean  "del_flg",         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "running_at"
  end

  create_table "batch_logs", force: true do |t|
    t.integer  "graph_id",                        null: false
    t.integer  "status_type_id",                  null: false
    t.integer  "status2_type_id",                 null: false
    t.integer  "batch_job_id",                    null: false
    t.boolean  "del_flg",         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "batch_periods", force: true do |t|
    t.string   "name",                       null: false
    t.boolean  "del_flg",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "batch_statuses", force: true do |t|
    t.integer  "graph_id",                         null: false
    t.integer  "status_id"
    t.integer  "status2_id"
    t.integer  "last_executed_at",                 null: false
    t.boolean  "del_flag",         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "batch_urls", force: true do |t|
    t.string   "url",                        null: false
    t.string   "ssh_key",                    null: false
    t.boolean  "del_flg",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user",                       null: false
    t.string   "pass"
    t.integer  "suffix_id",                  null: false
  end

  create_table "contacts", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "encodes", force: true do |t|
    t.string   "name",                       null: false
    t.boolean  "del_flg",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "information_types", force: true do |t|
    t.string   "name"
    t.string   "del_flag",   default: "0"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", force: true do |t|
    t.integer  "user_id",                  null: false
    t.string   "name",                     null: false
    t.string   "name_read",                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name2",                    null: false
    t.string   "name_read2",               null: false
    t.integer  "auth_type_id", default: 3
    t.integer  "station_id",   default: 1, null: false
    t.integer  "unit_id",      default: 1, null: false
    t.datetime "deleted_at"
  end

  add_index "profiles", ["deleted_at"], name: "index_profiles_on_deleted_at", using: :btree

  create_table "stations", force: true do |t|
    t.string   "name_ja",                    null: false
    t.boolean  "del_flag",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stations", ["name_ja"], name: "index_stations_on_name_ja", unique: true, using: :btree

  create_table "units", force: true do |t|
    t.string   "name_ja",                    null: false
    t.boolean  "del_flag",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "station_id", default: 1
  end

  add_index "units", ["station_id", "name_ja"], name: "index_units_name_ja_multiple_idx", using: :btree
  add_index "units", ["station_id"], name: "index_units_name_en_multiple_idx", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.datetime "expired_at"
    t.datetime "last_visited_at"
  end

  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
