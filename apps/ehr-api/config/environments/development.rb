# apps/ehr-api/config/environments/development.rb
# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Don't filter any parameters (e.g., passwords) so they show up in logs
  config.filter_parameters = [:password_confirmation]

  # Settings specified here will take precedence over those in config/application.rb.

  # Make code changes take effect immediately without server restart.
  config.enable_reloading = true

  # Restart the server when any boot-time Ruby file changes. Rails' reloader handles
  # Zeitwerk-autoloaded code (app/**) automatically. Everything below runs once at boot
  # and falls outside that scope — changes require a full restart.
  #
  # config/   — application.rb, environments/*, initializers/*, routes.rb, puma.rb, etc.
  #             Rails already watches routes.rb and locales; Listen deduplicates, no double restart.
  # lib/      — non-autoloaded support code; watch proactively so additions are picked up.
  config.watchable_dirs[Rails.root.join('config').to_s] = [:rb]
  config.watchable_dirs[Rails.root.join('lib').to_s]    = [:rb]

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing.
  config.server_timing = true

  # Enable/disable Action Controller caching. By default Action Controller caching is disabled.
  # Run rails dev:cache to toggle Action Controller caching.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.public_file_server.headers = { 'cache-control' => "public, max-age=#{2.days.to_i}" }
  else
    config.action_controller.perform_caching = false
  end

  # Change to :null_store to avoid any caching.
  config.cache_store = :memory_store

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Append comments with runtime information tags to SQL queries in logs.
  config.active_record.query_log_tags_enabled = true

  # Highlight code that triggered redirect in logs.
  config.action_dispatch.verbose_redirect_logs = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

  # Inject LiveReload script into HTML responses (ActiveAdmin pages) so the browser
  # refreshes automatically when guard-livereload detects file changes.
  require 'rack-livereload'
  config.middleware.use Rack::LiveReload
end
