#!/usr/bin/env bash
# bin/steps/13_active-admin.sh

source "$(dirname "$0")/../_lib.sh"

info "Adding ActiveAdmin..."
bundle add activeadmin
rails generate active_admin:install
bin/rails g active_admin:install
bin/rails generate devise AdminUser
bin/rails db:migrate
# TODO config ActiveAdmin to use Devise for authentication
