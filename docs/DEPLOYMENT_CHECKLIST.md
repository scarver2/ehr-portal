# Deployment Checklist: Rodauth Migration

Use this checklist when deploying the Rodauth migration to production.

## Pre-Deployment (24 hours before)

- [ ] Backup production database
  ```bash
  pg_dump ehr_api_production > backup-$(date +%Y%m%d-%H%M%S).sql
  ```

- [ ] Notify stakeholders of deployment window
  - Expected downtime: 5-10 minutes during migration
  - Notify clinical staff if applicable

- [ ] Review deployment plan with team
  - Confirm rollback procedure
  - Assign on-call engineer for post-deployment monitoring

- [ ] Test migration on staging environment
  ```bash
  RAILS_ENV=staging rails db:migrate
  RAILS_ENV=staging bin/test
  ```

- [ ] Verify all tests pass locally
  ```bash
  bin/test
  ```

## Deployment Day

### Pre-Deployment Checks

- [ ] Verify git branch is clean
  ```bash
  git status  # Should be clean
  ```

- [ ] Confirm deployment environment
  ```bash
  echo $RAILS_ENV  # Should be production
  echo $GITHUB_ENV  # Confirm correct deployment
  ```

- [ ] Take final backup
  ```bash
  pg_dump ehr_api_production > backup-pre-migration-$(date +%s).sql
  ```

- [ ] Notify operations team
  - Deployment starting in 5 minutes
  - Monitor logs for errors

### Deployment Steps

1. **Code Deployment**
   ```bash
   git pull origin main
   bundle install --deployment
   yarn install  # If applicable
   ```

2. **Database Migration**
   ```bash
   bundle exec rails db:migrate RAILS_ENV=production
   ```

3. **Asset Compilation**
   ```bash
   bundle exec rails assets:precompile RAILS_ENV=production
   ```

4. **Restart Application**
   ```bash
   systemctl restart puma  # or your app server
   systemctl restart sidekiq  # background jobs
   ```

5. **Clear Cache**
   ```bash
   bundle exec rails cache:clear RAILS_ENV=production
   bundle exec rails tmp:clear RAILS_ENV=production
   ```

## Post-Deployment

### Immediate Checks (First 5 Minutes)

- [ ] Application is running
  ```bash
  curl https://ehr-api.example.com/api/up
  # Should return: { status: "ok" }
  ```

- [ ] Admin dashboard accessible
  ```bash
  curl -i https://ehr-api.example.com/admin/login
  # Should return HTTP 200
  ```

- [ ] GraphQL endpoint working
  ```bash
  curl -X POST https://ehr-api.example.com/graphql \
    -H "Content-Type: application/json" \
    -d '{"query": "{ __schema { types { name } } }"}'
  # Should return schema information
  ```

- [ ] No critical errors in logs
  ```bash
  tail -100 log/production.log | grep -i error
  # Should be minimal/normal errors only
  ```

### Functional Checks (5-30 Minutes)

- [ ] Test user login with existing credentials
  ```bash
  curl -X POST https://ehr-api.example.com/api/v1/auth/login \
    -H "Content-Type: application/json" \
    -d '{
      "user": {
        "email": "provider@example.com",
        "password": "their_password"
      }
    }'
  # Should return: { user: {...}, token: "eyJ..." }
  ```

- [ ] Test GraphQL query with token
  ```bash
  TOKEN="<token_from_login>"
  curl -X POST https://ehr-api.example.com/graphql \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{"query": "{ currentUser { id email } }"}'
  # Should return current user data
  ```

- [ ] Test portal login flow
  - Open https://ehr-portal.example.com
  - Login with test credentials
  - Verify user data loads
  - Verify access to expected resources

- [ ] Test admin login
  - Open https://ehr-api.example.com/admin
  - Login with admin credentials
  - Verify admin dashboard loads

- [ ] Monitor user login rates
  ```bash
  # Check Sidekiq dashboard or logs
  tail -f log/production.log | grep "login\|auth"
  # Should see normal login activity
  ```

- [ ] Check database status
  ```bash
  # Via Rails console
  rails console -e production
  > Account.count  # Should show account records
  > Role.count     # Should show role records
  > User.count     # Should show user records
  ```

### Extended Monitoring (30 Minutes - 2 Hours)

- [ ] Monitor application error rate
  - Check error tracking (Sentry, Rollbar, etc.)
  - Should see no unusual spikes
  - JWT decode errors would indicate problems

- [ ] Check response times
  - Login endpoint: <500ms
  - GraphQL queries: <100ms
  - API endpoints: <200ms

- [ ] Monitor database performance
  - Connection count normal
  - Query times normal
  - No deadlocks in logs

- [ ] Monitor Redis/cache
  ```bash
  redis-cli info
  # Check memory usage
  # Check connected clients
  ```

- [ ] Check authentication logs
  ```bash
  tail -100 log/production.log | grep -i "account\|auth\|jwt"
  # Look for patterns of failures
  ```

## Rollback Plan (If Needed)

**Decision Point:** If critical issues arise in first 2 hours

### Quick Rollback

1. **Revert code**
   ```bash
   git revert <commit_hash>
   git push origin main
   ```

2. **Rollback database** (if migrations had issues)
   ```bash
   rails db:rollback STEP=4 RAILS_ENV=production
   ```

3. **Restart application**
   ```bash
   systemctl restart puma
   systemctl restart sidekiq
   ```

4. **Verify rollback**
   ```bash
   curl https://ehr-api.example.com/api/up
   # Should work with old code
   ```

5. **Notify stakeholders**
   - Explain what went wrong
   - Provide timeline for retry
   - Document lessons learned

### From Database Backup (If Severe Issues)

**Only if absolutely necessary (data loss risk)**

```bash
# Stop application
systemctl stop puma sidekiq

# Restore from backup
dropdb ehr_api_production
createdb ehr_api_production
pg_restore --clean backup-pre-migration-<timestamp>.sql > /tmp/restore.log

# Revert code
git revert <commit>
git push origin main

# Restart
systemctl start puma sidekiq

# Verify
curl https://ehr-api.example.com/api/up
```

## Post-Deployment (24+ Hours)

- [ ] Monitor for 24 hours
  - No unusual error spikes
  - Normal user activity
  - Response times stable

- [ ] Run full test suite against production-like data
  ```bash
  # If safe to do so:
  bundle exec rake test:all RAILS_ENV=production
  ```

- [ ] Verify data integrity
  ```bash
  rails console -e production
  > User.all.select { |u| u.account.nil? }
  # Should be empty (all users have accounts)

  > User.all.select { |u| u.roles.empty? }
  # Should be empty (all users have roles)
  ```

- [ ] Confirm admin user still exists
  ```bash
  rails console -e production
  > AdminUser.exists?(email: "admin@example.com")
  # Should be true
  ```

- [ ] Clean up old backup files
  ```bash
  # Keep latest backup, remove others older than 30 days
  ls -la backup-*.sql
  ```

## Monitoring (Ongoing)

### Critical Alerts to Set Up

```
Alert: JWT Decode Errors
- If rate > 10/min for 5 min, investigate
- Could indicate token format issues or time skew

Alert: Login Failures
- If rate > 5% of attempts, investigate
- Could indicate password migration issues

Alert: Database Connections
- If > 90% of max connections
- Could indicate slow queries or connection leak

Alert: Account Status Anomalies
- Check for unexpected account status changes
- Look for locked-out accounts
```

### Logs to Monitor

```bash
# Daily log review
grep "JWT\|decode\|token" log/production.log | tail -100

# Account audit logs
rails console -e production
> AccountAuditLog.last(20).map { |log| puts log.message }
```

## Success Criteria

✅ Deployment successful if:
- No critical errors in logs (first 2 hours)
- Users can login with existing credentials
- GraphQL queries work with JWT tokens
- Admin dashboard accessible
- Response times normal
- No unusual error spikes
- Database integrity maintained

❌ Rollback if:
- Users cannot login
- GraphQL authentication broken
- Admin dashboard inaccessible
- Critical error rate > 5%
- Response times degraded > 50%

## Communication Template

### Pre-Deployment Notification

```
Subject: Scheduled Maintenance - EHR Portal Auth System Update

Dear Users,

We will be performing scheduled maintenance on the EHR Portal
authentication system on [DATE] at [TIME] for approximately 5-10 minutes.

During this maintenance window:
- You may be unable to login
- Existing sessions will remain active
- No patient data will be affected

After the update:
- All existing logins will work as before
- No action needed on your part
- New authentication system will be faster and more secure

Thank you for your patience.
```

### Post-Deployment Notification (If Successful)

```
Subject: EHR Portal Maintenance Complete

Dear Users,

The scheduled authentication system upgrade is complete.

What changed:
- More secure JWT-based authentication
- Faster login and data access
- Better security isolation between portal and admin areas

What stays the same:
- You login the same way
- All your permissions unchanged
- No new passwords needed

If you experience any issues, please contact IT Support.
```

## Additional Resources

- [Migration Documentation](./MIGRATION.md)
- [Architecture Documentation](./AUTHENTICATION.md)
- [Troubleshooting Guide](./MIGRATION.md#troubleshooting-migration)
- [Deployment Logs](../log/production.log)
- [Database Backups](../backups/)
- [Incident Response Plan](./INCIDENT_RESPONSE.md) (if exists)

## Sign-Off

| Role | Name | Date | Sign-Off |
|------|------|------|----------|
| Dev Lead | | | |
| DevOps | | | |
| QA Lead | | | |
| Product Owner | | | |

