# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += [/^[a-z0-9]\w+.(css|js|woff|eot|svg|ttf|less)$/, /^[a-z0-9]\w+\/[a-z0-9]\w+.(css|js|woff|eot|svg|ttf|less)$/, /^[a-z0-9]\w+\/[a-z0-9]\w+\/[a-z0-9]\w+.(css|js|woff|eot|svg|ttf|less)$/]

Rails.application.config.assets.precompile += %w( paper.css )

# add.
Rails.application.config.assets.precompile += %w( lib/* )
Rails.application.config.assets.precompile += %w( top/* )
Rails.application.config.assets.precompile += %w( line_graph/issp/* )
Rails.application.config.assets.precompile += %w( line_graph/issp/hour/* )
Rails.application.config.assets.precompile += %w( trulia_trend/issp/* )
Rails.application.config.assets.precompile += %w( users/registrations/* )
