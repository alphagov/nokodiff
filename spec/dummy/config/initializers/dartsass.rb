APP_STYLESHEETS = {
  "application.scss" => "application.css",
}.freeze

Rails.application.config.dartsass.builds = APP_STYLESHEETS
Rails.application.config.dartsass.build_options << " --quiet-deps"
