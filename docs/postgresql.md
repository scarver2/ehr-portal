# EHR Portal: PostgreSQL

Open Postgres:

````bash
psql postgres
```

Then create the role and databases:

```
CREATE ROLE ehr_api LOGIN PASSWORD 'password';
ALTER ROLE ehr_api CREATEDB;

CREATE DATABASE ehr_api_development OWNER ehr_api;
CREATE DATABASE ehr_api_test OWNER ehr_api;
CREATE DATABASE ehr_api_production OWNER ehr_api;
\q
```

