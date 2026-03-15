# bin/steps/31_providers_modeling.sh

# Schema:
# first_name:string
# last_name:string
# npi:string
# taxonomy:string
# address:string
# phone:string
# email:string
# website:string

# Steps:
# 1. Generate Provider model in Rails
# 2. Generate Provider resource in ActiveAdmin
# 3. Generate Provider type in GraphQL

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-api

bin/rails generate model Provider first_name:string last_name:string 

# Add Provider to ActiveAdmin
bin/rails generate active_admin:resource Provider

# Add Provider to GraphQL
bin/rails generate graphql:object Provider
