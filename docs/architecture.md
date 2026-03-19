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

    ┌─────────────────────────────────────────────────────────────┐
    │  Next.js Portal  (/insurance)                               │
    │  InsurancePage + useInsuranceVerificationStream hook        │
    │  @rails/actioncable consumer (wss://…/cable)               │
    └──────────┬──────────────────────────────────────────────────┘
               │ POST /api/insurance_verifications
               ▼
    ┌─────────────────────────────────────────────────────────────┐
    │  Rails API                                                  │
    │  Api::InsuranceVerificationsController#create               │
    │    → InsuranceVerification.create!                          │
    │    → verification.enqueue!  (AASM: pending → queued)        │
    │    → InsuranceVerificationWorker.perform_async              │
    └──────────┬──────────────────────────────────────────────────┘
               │ enqueue job
               ▼
    ┌─────────────────────────────────────────────────────────────┐
    │  Redis  (Sidekiq queue: insurance)                          │
    └──────────┬──────────────────────────────────────────────────┘
               │ worker picks up job
               ▼
    ┌─────────────────────────────────────────────────────────────┐
    │  InsuranceVerificationWorker                                │
    │                                                             │
    │  RteCache.read ──hit──► apply_cached_response               │
    │       │                   mark_verified! (queued→verified)  │
    │      miss                                                   │
    │       │                                                     │
    │  start_request! (queued → requesting)                       │
    │  FakePayerGateway#check_eligibility                         │
    │  mark_verified! (requesting → verified)                     │
    │  RteCache.write (12h TTL)                                   │
    │                                                             │
    │  on error → mark_failed! + persist error_message           │
    └──────────┬──────────────────────────────────────────────────┘
               │ broadcast!
               ▼
    ┌─────────────────────────────────────────────────────────────┐
    │  ActionCable / InsuranceVerificationChannel                 │
    │  stream_for current_user                                    │
    └──────────┬──────────────────────────────────────────────────┘
               │ WebSocket push
               ▼
    ┌─────────────────────────────────────────────────────────────┐
    │  React UI  (live status, payer, plan, copay, deductible,    │
    │  OOP max, error — rendered in InsurancePage)                │
    └─────────────────────────────────────────────────────────────┘

    PostgreSQL  ← InsuranceVerification record persisted at each state change
    React       ← GET /api/insurance_verifications/:id as WebSocket fallback

### Observer Trigger

When a patient's `InsuranceProfile` is created, `InsuranceProfileObserver#after_create`
automatically creates an `InsuranceVerification`, enqueues it, and dispatches the worker —
no explicit controller call required.

    InsuranceProfile.create!
        → InsuranceProfileObserver#after_create
        → InsuranceVerification.create! + enqueue! + broadcast!
        → InsuranceVerificationWorker.perform_async

### RTE State Machine

    pending → queued → requesting → verified
                     ↘            ↗ (cache hit: queued → verified directly)
                       → failed
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
