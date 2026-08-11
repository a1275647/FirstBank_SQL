# Country rating TVP / BMI Core deployment

## Preconditions

- Target database is `NCRMS` and the existing `dbo.ufn_table_GetCountryRating` and `dbo.usp_BmiRatingCount` objects are available.
- Take the normal database deployment backup/snapshot before applying the scripts.
- Do not run these scripts against an environment unless that environment and maintenance window have been explicitly approved.

## Required order

1. Run `CountryRatingResultType.sql` to create or validate `dbo.CountryRatingResultType`.
2. Run `StoredProcedure/usp_BmiRatingCount_Core.sql` to create the TVP-based Core procedure.
3. Run `StoredProcedure/usp_BmiRatingCount.sql` to replace the legacy procedure with the no-argument compatibility wrapper.
4. Deploy the AP changes only after all three database objects are available.

All three scripts are safe to run repeatedly. The type script never drops an existing type; it stops with an error if the existing contract differs. Both procedures use `CREATE OR ALTER`.

## Rollback

Before the AP cutover is accepted, switch AP callers back to parameterless `EXEC dbo.usp_BmiRatingCount`. The compatibility wrapper continues to populate the TVP from `dbo.ufn_table_GetCountryRating` and delegates the complete BMI implementation to Core, so no SQL object needs to be recreated for this rollback.

Do not remove the Core procedure, compatibility wrapper, table type, or legacy function in this ticket. Their retirement is gated by the later parity and observation tickets.
