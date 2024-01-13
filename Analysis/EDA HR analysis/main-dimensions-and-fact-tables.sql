# After importing table into MySQL, we separate the tables into its relevant dimensions and fact tables.
use joblevelgrpdata;
select*from divdata;

# Main table

SELECT * FROM fact_table;           -- This includes all columns except 'rand' and the three geographic columns (broad_region, region_group, country).

# Regions dimensions table

SELECT * FROM divdata;   -- This table was previously created in excel and imported in MySQL.

# Create employee dimension table
-- Columns were manually selected from main table to order them so looking at the data becomes easier whenever we query the table
SELECT 
`FactSurKey`,`EmpID`,`Gender`,`Age`,`AgeGroup`,`HireDate`,`FromDate`,`EndDate`,`YrsSinceLastHire`,
`ContractID`,`RegionCountryId`,`Department`,`JobLevel`,`PerfRating`,`JL-Promo`,`CurrentFlag`,`EmployedFlag`,
`LeaverFlag`,`NewHireFlag`,`TurnoverBaseGroup`,`PromoBaseGroup`,`JLGroupPraId`,`Fy20JLGroupPra`,`Fy20JLGroupPraStatus`,
`Fy20JLDeptGroupPraId`,`Fy20JLDeptGroupPra`,`Fy20JLDeptGroupPraStatus` from fact_table;

# Create fact table

SELECT `EmpID`,`Fy20JLGroupPra`,`Fy20JLGroupPraStatus`,`Fy20JLDeptGroupPra`, `Fy20JLDeptGroupPraStatus`
FROM fact_table;
