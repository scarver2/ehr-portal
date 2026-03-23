# config/initializers/rack_profiler.rb
# frozen_string_literal: true

# rack-mini-profiler — speed badge on ActiveAdmin pages + ?pp=flamegraph endpoint.
# stackprof provides CPU/allocation flame graphs when ?pp=flamegraph is appended to any URL.
#
# Usage:
#   ?pp=help          list all options
#   ?pp=flamegraph    CPU flame graph (requires stackprof)
#   ?pp=flamegraph&pp=flamegraph_sample_rate=1000
#   ?pp=profile-memory  allocation profiling
#   ?pp=disable / ?pp=enable  toggle the badge

return unless Rails.env.development?

require 'rack-mini-profiler'
require 'stackprof'

Rack::MiniProfiler.config.position                           = 'bottom-right'
Rack::MiniProfiler.config.enabled                            = true
Rack::MiniProfiler.config.enable_hotwire_turbo_drive_support = false
