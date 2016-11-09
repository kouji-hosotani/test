require File.expand_path('../boot', __FILE__)
require 'rails/all'
Bundler.require(*Rails.groups)

module Testmail
  class Application < Rails::Application

    config.assets.enabled = true
    config.assets.paths << Rails.root.join("app", "assets", "fonts")
    config.time_zone = 'Asia/Tokyo'
    config.active_record.default_timezone = :local
    config.i18n.default_locale = :ja
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    # less-rails gem (default all generators)
    #config.app_generators.stylesheet_engine :less
    #config.less.paths << "#{Rails.root}/lib/less/protractor/stylesheets"
    #config.less.compress = true

    # for batch scripts
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # for activerecord.
    config.generators do |g|
        g.orm :active_record
    end

    require "i18n/backend/fallbacks"
    I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
    config.i18n.fallbacks = {'ja' => 'en'}

    # error statement
    config.error = {
        "1" => "APIとの通信でエラーが発生しました",
        "2" => "経路を選択してください",
        "3" => "サービスを選択してください",
        "4" => "開始日時を選択してください",
        "5" => "終了日時を選択してください",
        "1001" => "予期しないエラーが発生しました"
    }

   # Mailer with Amazon SES
    # config.action_mailer.delivery_method = :aws_sdk
    # config.action_mailer.default_url_options = { :host => 'mediba.jp' }
    config.action_mailer.raise_delivery_errors = true

    # boolean を0/1で扱う設定
    require 'active_record/connection_adapters/mysql2_adapter'
    ActiveRecord::ConnectionAdapters::Mysql2Adapter.emulate_booleans = true

  end
end
