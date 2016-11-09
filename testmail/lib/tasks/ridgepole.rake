namespace :ridgepole do
  desc "Exec Apply Dry Run"
  task apply_dry_run: :environment do
    exec "bundle exec ridgepole -c config/ridgepole//#{Rails.env}.yml -E #{Rails.env} -f #{Rails.root}/config/ridgepole/Schemafile --apply --dry-run"
  end

  desc "Exec Apply"
  task apply: :environment do
    exec "bundle exec ridgepole -c config/ridgepole/#{Rails.env}.yml -E #{Rails.env} -f #{Rails.root}/config/ridgepole/Schemafile --apply"
  end
end
