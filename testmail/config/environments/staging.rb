Rails.application.configure do
  #config.cache_classes = true
  #config.eager_load = true
  #config.consider_all_requests_local       = true
  #config.action_controller.perform_caching = true
  #config.serve_static_files = false

  #config.assets.js_compressor = :uglifier
  #config.assets.css_compressor = :sass
  #config.assets.compile = true
  #config.assets.digest = true
  #config.log_level = :info

  #add
  #config.assets.precompile += [/^[a-z0-9]\w+.(css|js|less|font)$/, /^[a-z0-9]\w+\/[a-z0-9]\w+.(css|js|less|font)$/, /^[a-z0-9]\w+\/[a-z0-9]\w+\/[a-z0-9]\w+.(css|js|less|font)$/]

  #config.assets.initialize_on_precompile = true
  #config.assets.digest = true
  #config.requirejs.logical_asset_filter += [/\.haml$/, /\.coffee$/]
  #config.i18n.fallbacks = true
  #config.active_support.deprecation = :notify
  #config.log_formatter = ::Logger::Formatter.new
  #config.active_record.dump_schema_after_migration = false

  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_mailer.raise_delivery_errors = true
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.assets.debug = true
  config.assets.raise_runtime_errors = true
  config.i18n.default_locale = :ja

end
