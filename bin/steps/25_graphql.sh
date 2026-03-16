# bin/steps/25_graphql.sh

source "$(dirname "$0")/../_lib.sh"

cd apps/ehr-portal

info "Adding graphql-request dependency..."
bun add graphql-request
