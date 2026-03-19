# apps/ehr-api/db/seeds/medical_specialties.rb
# frozen_string_literal: true

puts "Seeding medical specialties..."

Specialty.insert_all(
  [
    { name: "Allergy & Immunology",               category: "Medical",      created_at: Time.current, updated_at: Time.current },
    { name: "Anesthesiology",                      category: "Surgical",     created_at: Time.current, updated_at: Time.current },
    { name: "Cardiology",                          category: "Medical",      created_at: Time.current, updated_at: Time.current },
    { name: "Colorectal Surgery",                  category: "Surgical",     created_at: Time.current, updated_at: Time.current },
    { name: "Critical Care Medicine",              category: "Medical",      created_at: Time.current, updated_at: Time.current },
    { name: "Dermatology",                         category: "Medical",      created_at: Time.current, updated_at: Time.current },
    { name: "Emergency Medicine",                  category: "Medical",      created_at: Time.current, updated_at: Time.current },
    { name: "Endocrinology",                       category: "Medical",      created_at: Time.current, updated_at: Time.current },
    { name: "ENT / Otolaryngology",               category: "Surgical",     created_at: Time.current, updated_at: Time.current },
    { name: "Family Medicine",                     category: "Primary Care", created_at: Time.current, updated_at: Time.current },
    { name: "Gastroenterology",                    category: "Medical",      created_at: Time.current, updated_at: Time.current },
    { name: "Geriatric Medicine",                  category: "Primary Care", created_at: Time.current, updated_at: Time.current },
    { name: "Hematology",                          category: "Medical",      created_at: Time.current, updated_at: Time.current },
    { name: "Infectious Disease",                  category: "Medical",      created_at: Time.current, updated_at: Time.current },
    { name: "Internal Medicine",                   category: "Primary Care", created_at: Time.current, updated_at: Time.current },
    { name: "Nephrology",                          category: "Medical",      created_at: Time.current, updated_at: Time.current },
    { name: "Neurology",                           category: "Medical",      created_at: Time.current, updated_at: Time.current },
    { name: "Neurosurgery",                        category: "Surgical",     created_at: Time.current, updated_at: Time.current },
    { name: "Obstetrics & Gynecology",             category: "Surgical",     created_at: Time.current, updated_at: Time.current },
    { name: "Oncology",                            category: "Medical",      created_at: Time.current, updated_at: Time.current },
    { name: "Ophthalmology",                       category: "Surgical",     created_at: Time.current, updated_at: Time.current },
    { name: "Orthopedic Surgery",                  category: "Surgical",     created_at: Time.current, updated_at: Time.current },
    { name: "Pain Management",                     category: "Medical",      created_at: Time.current, updated_at: Time.current },
    { name: "Pediatrics",                          category: "Primary Care", created_at: Time.current, updated_at: Time.current },
    { name: "Physical Medicine & Rehabilitation",  category: "Medical",      created_at: Time.current, updated_at: Time.current },
    { name: "Plastic Surgery",                     category: "Surgical",     created_at: Time.current, updated_at: Time.current },
    { name: "Psychiatry",                          category: "Medical",      created_at: Time.current, updated_at: Time.current },
    { name: "Pulmonology",                         category: "Medical",      created_at: Time.current, updated_at: Time.current },
    { name: "Radiology",                           category: "Medical",      created_at: Time.current, updated_at: Time.current },
    { name: "Rheumatology",                        category: "Medical",      created_at: Time.current, updated_at: Time.current },
    { name: "Urology",                             category: "Surgical",     created_at: Time.current, updated_at: Time.current }
  ],
)

puts "  → #{Specialty.count} specialties seeded."
