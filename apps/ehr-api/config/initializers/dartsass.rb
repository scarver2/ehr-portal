# config/initializers/dartsass.rb
# frozen_string_literal: true

Rails.application.config.dartsass.builds = {
  'application.scss' => 'application.css',
  'active_admin.scss' => 'active_admin.css'
}

# Silence Sass deprecation warnings that originate inside the activeadmin gem's
# own SCSS files. We cannot fix these — they are inside the gem. The warnings
# are pre-emptive notices that Dart Sass 3.0.0 will remove the old @import
# syntax and legacy color functions. CSS still compiles correctly today.
#
# Remove these suppression flags once ActiveAdmin ships SCSS that uses the
# modern @use / @forward module system and sass:color functions.
#
# https://sass-lang.com/d/import         — @import deprecation
# https://sass-lang.com/d/color-functions — lighten() / darken() deprecation
Rails.application.config.dartsass.build_options += %w[
  --silence-deprecation=import
  --silence-deprecation=global-builtin
  --silence-deprecation=color-functions
]
