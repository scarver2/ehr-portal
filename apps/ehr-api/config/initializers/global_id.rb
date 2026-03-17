# frozen_string_literal: true

# GlobalID::Railtie is not loaded because this API-only app opts out of
# activejob and activestorage (the railties that normally require it).
# Set the app name manually so that to_gid_param / GlobalID.find work.
GlobalID.app = "ehr-api"
