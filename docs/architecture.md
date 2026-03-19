# EHR Portal Architecture

## Standard Request Flow

    Browser
        ↓
    Next.js Portal
        ↓ GraphQL / REST
    Rails API
        ↓
    PostgreSQL

## Real-Time Eligibility (RTE) Flow

    React (Next.js)
        ↓ POST /api/insurance_verifications
    Rails API
        ↓ InsuranceVerificationWorker.perform_async
    Redis (Sidekiq queue)
        ↓ Worker picks up job
    InsuranceVerificationWorker
        ↓ RteCache.read → cache hit? apply cached response
        ↓ FakePayerGateway → Insurance Clearinghouse API
        ↓ RteCache.write (12h TTL)
        ↓ mark_verified! + broadcast!
    ActionCable → WebSocket
        ↓
    React UI (live status update)

    PostgreSQL (InsuranceVerification record persisted)
    React polls GET /api/insurance_verifications/:id as fallback

### RTE State Machine

    pending → queued → requesting → parsing → verified
                                  ↘ failed
    verified → expired
    pending/queued → canceled

### Clearinghouse / Payer APIs

- **Change Healthcare** — BCBSTX
- **Availity** — Aetna, Cigna
- **Optum** — UnitedHealthcare
- **Waystar** — Humana
- **CMS** — Medicare
- **State (TMHP)** — Medicaid Texas

## License

Copyright &copy;2026 [Stan Carver II](http://stancarver.com) All rights reserved.

![Made in Texas](https://raw.githubusercontent.com/scarver2/howdy-world/master/_dashboard/www/assets/made-in-texas.png)
