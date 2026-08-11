# Country rating TVP / BMI direct cutover

## Preconditions

- Target database is `NCRMS`; the existing `dbo.usp_BmiRatingCount` and
  `dbo.ufn_table_GetCountryRating` objects are available.
- Take the normal database deployment backup/snapshot before applying scripts.
- Reserve one maintenance window in which the CreditRatings jobs remain paused.
- Do not run these scripts unless the target environment and window have been
  explicitly approved.

## Deployment

This delivery changes only the existing `dbo.usp_BmiRatingCount`; it does not
create `dbo.usp_BmiRatingCount_Core` or another BMI stored procedure.

Apply the release in this order:

1. Pause every application job or caller that can execute
   `dbo.usp_BmiRatingCount`.
2. Run `20260811/CountryRatingResultType.sql` to create or validate
   `dbo.CountryRatingResultType`.
3. Run `20260811/StoredProcedure/usp_BmiRatingCount.sql`. It changes the
   existing procedure to accept `@Date` plus the readonly country-rating TVP
   and contains the complete BMI calculation body.
4. Deploy the matching FirstBank API and CreditRatings builds.
5. Verify the procedure signature and one approved non-production schedule run
   before resuming normal jobs.

The type and procedure scripts are safe to run repeatedly after their stated
prerequisites are met. The procedure reads country ratings only from the TVP;
it does not call `GETDATE()` to choose the business date and does not call
`dbo.ufn_table_GetCountryRating`.

## Compatibility window

SQL Server cannot overload one procedure name with both the old no-argument
signature and the new `@Date + TVP` signature. Because no compatibility/Core
procedure is introduced, the old application and new database contract are not
cross-compatible. Keep callers paused while steps 2–4 are performed; do not
deploy the database and application independently outside the same maintenance
window.

## Validation

Country-rating parity can be collected before deployment with the read-only
observer. BMI parity must use approved pre-deployment and post-deployment
snapshots from the same controlled non-production dataset because both stored
procedure signatures cannot coexist under the same object name. Classify and
resolve every difference before production cutover.

## Rollback

Rollback must restore the database and application together:

1. Pause all `dbo.usp_BmiRatingCount` callers.
2. Restore the pre-deployment database backup/snapshot, or restore the legacy
   procedure definition from FirstBank_SQL commit `9857530`
   (`StoredProcedure/usp_BmiRatingCount.sql`).
3. Deploy the verified pre-Ticket 01 API/CreditRatings pair
   (`0df6635e` / `a9840c2`) when a full legacy country-rating rollback is
   required.
4. Validate the no-argument procedure and legacy schedule path before resuming
   jobs.

The legacy function remains available for this manual rollback. Its eventual
removal remains user-owned cleanup and is not performed by these scripts.
