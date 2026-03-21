# db/seeds/payers.rb
# frozen_string_literal: true

payers = [
  {
    name:             "Aetna",
    payer_code:       "AETNA001",
    clearinghouse:    "Availity",
    api_endpoint:     "https://api.availity.com/eligibility",
    requires_auth:    true,
    response_time_ms: 1200
  },
  {
    name:             "Blue Cross Blue Shield of Texas",
    payer_code:       "BCBSTX",
    clearinghouse:    "ChangeHealthcare",
    api_endpoint:     "https://api.changehealthcare.com/eligibility",
    requires_auth:    true,
    response_time_ms: 1800
  },
  {
    name:             "UnitedHealthcare",
    payer_code:       "UHC001",
    clearinghouse:    "Optum",
    api_endpoint:     "https://api.optum.com/rte",
    requires_auth:    true,
    response_time_ms: 1500
  },
  {
    name:             "Cigna",
    payer_code:       "CIGNA01",
    clearinghouse:    "Availity",
    api_endpoint:     "https://api.availity.com/cigna/eligibility",
    requires_auth:    true,
    response_time_ms: 1400
  },
  {
    name:             "Humana",
    payer_code:       "HUMANA01",
    clearinghouse:    "Waystar",
    api_endpoint:     "https://api.waystar.com/eligibility",
    requires_auth:    true,
    response_time_ms: 1700
  },
  {
    name:             "Medicare",
    payer_code:       "MEDICARE",
    clearinghouse:    "CMS",
    api_endpoint:     "https://api.cms.gov/eligibility",
    requires_auth:    false,
    response_time_ms: 2000
  },
  {
    name:             "Medicaid - Texas",
    payer_code:       "TXMEDICAID",
    clearinghouse:    "State",
    api_endpoint:     "https://api.tmhp.com/eligibility",
    requires_auth:    true,
    response_time_ms: 2200
  }
]

payers.each do |attrs|
  Payer.find_or_create_by!(payer_code: attrs[:payer_code]) do |payer|
    payer.assign_attributes(attrs.merge(active: true))
  end
end

puts "Seeded #{Payer.count} payers"
