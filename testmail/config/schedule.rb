# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, "log/crontab.log"
# RAILS_ENV=development bundle exec whenever --update-crontab
# RAILS_ENV=development bundle exec whenever --clear-cron
# 各環境にて上記コマンドを実行する際、environment の値を適宜修正する
set :environment, :production 

# MapReduceの実行 1日分
every 1.day, :at => '3:00 am' do
  rake '"tuna_map_reduce:exec_by_range[all, 2]"'
end
