# Country rating TVP / BMI deployment and formal cutover

## Preconditions

- Target database is `NCRMS` and the existing `dbo.ufn_table_GetCountryRating` and `dbo.usp_BmiRatingCount` objects are available.
- Take the normal database deployment backup/snapshot before applying the scripts.
- Do not run these scripts against an environment unless that environment and maintenance window have been explicitly approved.

## Ticket 02 compatibility deployment

1. Run `CountryRatingResultType.sql` to create or validate `dbo.CountryRatingResultType`.
2. Run `StoredProcedure/usp_BmiRatingCount_Core.sql` to create the TVP-based Core procedure.
3. Run `StoredProcedure/usp_BmiRatingCount.sql` to replace the legacy procedure with the no-argument compatibility wrapper.
4. Deploy the AP changes only after all three database objects are available.

All three scripts are safe to run repeatedly. The type script never drops an existing type; it stops with an error if the existing contract differs. Both procedures use `CREATE OR ALTER`.

## Ticket 03 formal cutover

Do not perform the formal cutover until the country-rating parity evidence has
no unexplained differences and the target environment has completed the
required BMI comparison and representative schedule observation.

The formal cutover must be applied in this order:

1. Confirm `dbo.CountryRatingResultType` and
   `dbo.usp_BmiRatingCount_Core` already exist with the Ticket 02 contracts.
2. Run `StoredProcedure/usp_BmiRatingCount.sql`. This changes the formal
   procedure to require `@Date` and `@CountryRatings` and delegate to Core.
3. Deploy the Ticket 03 AP build, whose executor calls
   `dbo.usp_BmiRatingCount @Date, @CountryRatings`.

SQL must be applied before the Ticket 03 AP build. The previous Ticket 02 AP
continues to call Core directly while step 2 is being applied, so this order
does not create an incompatible window. Deploying the new AP first would make
it call a formal procedure that still has the old no-argument signature.

The Ticket 03 procedure script uses `CREATE OR ALTER` and is safe to run
repeatedly after its type/Core prerequisites are present. It does not call
`GETDATE()` or `dbo.ufn_table_GetCountryRating`.

## Rollback

There are two rollback depths:

1. To roll back only the Ticket 03 formal caller/contract, first deploy the
   Ticket 02 AP build. It calls Core directly and therefore works with either
   formal-procedure signature. Then run
   `Rollback/usp_BmiRatingCount_Ticket02_CompatibilityWrapper.sql` to restore
   the no-argument wrapper. This is a safe bridge, but it does not by itself
   restore legacy country-rating behavior because the Ticket 02 AP still calls
   Core directly.
2. To roll back an AP country-rating or TVP defect fully to legacy behavior,
   complete step 1 and then deploy the pre-Ticket 02 / Ticket 01 CreditRatings
   build (`787600c`). That build calls the restored no-argument wrapper, which
   populates the TVP from the legacy function before delegating to Core. Keep
   the Ticket 01 API build (`8d31a0e`) paired with it when rolling back the
   shared service contract. This sequence avoids an incompatible caller window
   and makes the legacy function the effective country-rating source again.

Do not remove Core, the table type, or the legacy function in Ticket 03. Their
retirement is the separate Ticket 04 irreversible cleanup.
