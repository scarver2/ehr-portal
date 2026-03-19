# EHR Portal Architecture


## API Request Flow

    Browser
        ↓
    Next.js Portal
        ↓
    GraphQL API (Rails)
        ↓
    Redis Cache
        ↓
    PostgreSQL


## Auth Flow
# TODO: Add RBAC information&steps/flow


    NextJS
       │
       │ login
       ▼
    POST /api/auth/login
       │
       │ JWT returned
       ▼
   NextJS stores token
       │
       │ Authorization header
       ▼
    Rails API


## License

Copyright &copy;2026 [Stan Carver II](http://stancarver.com) All rights reserved.

![Made in Texas](https://raw.githubusercontent.com/scarver2/howdy-world/master/_dashboard/www/assets/made-in-texas.png)
