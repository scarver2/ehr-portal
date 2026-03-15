# bin/steps/30_providers_modeling.sh

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

cd apps/ehr-api

bin/rails g model Provider first_name:string last_name:string 
# TODO: npi:string taxonomy:string address:string phone:string email:string website:string

# Add Provider to ActiveAdmin
# bin/rails g migration AddProviderToActiveAdmin
# ActiveAdmin.register Provider

# Add Provider to GraphQL
bin/rails g graphql:object Provider
