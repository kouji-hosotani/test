# encoding: utf-8

namespace :seed do
  desc "make sample login user"
  # Account Info -> winoo@mediba.jp / hogehoge
  # Command Exp: $ RAILS_ENV=development bundle exec rake seed:insert
  task insert: :environment do |task|
    user = User.new 
    user.email    = "winoo@mediba.jp"
    user.password = "hogehoge"
    user.save!
  end
end
