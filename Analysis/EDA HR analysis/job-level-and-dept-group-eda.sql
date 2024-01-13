use joblevelgrpdata;
SELECT * FROM `job level and grp data`;
alter table `job level and grp data` rename to fact_table;
select*from fact_table;
select*from divdata;
SELECT * FROM dimtable;
-- -------------------------------------------------------------------
# # # # # # # # # # # # # JOB & DEPT LEVEL # # # # # # # # # # # # # # 
-- -------------------------------------------------------------------

-- Aside from the stated jl_dept that is uneven, we should also try to find which other job level & department is uneven + total count (incl FY20 leavers)
SELECT DISTINCT Fy20JLGroupPra, COUNT(EmpID) AS total_emp_count
FROM fact_table
WHERE `Fy20JLDeptGroupPraStatus` = "Uneven - Men benefit"
GROUP BY 1

-- Find the gender & age group breakdown of the job dept level (3 - Senior Manager Internal Services, 3 - Senior Manager S&M, 4 - Manager S&M)

-- STEP 1: Get emp number breakdown by job + dept level, gender & age
-- CREATE TEMPORARY TABLE jl_dept_by_gender_age
SELECT `Fy20JLDeptGroupPra` AS jl_dept_level, de.gender, de.age_group,
COUNT(CASE WHEN de.gender = "M" THEN de.EmpID ELSE de.EmpID END) AS tot_emp
FROM dimtable as de LEFT JOIN fact_table f ON f.emp_id = de.emp_id 
WHERE `Fy20JLDeptGroupPraStatus` = "Uneven - Men benefit"
GROUP BY 1, 2, 3
ORDER BY 1 DESC, 4 DESC

-- STEP 2: Display grand total column next to tot_emp
-- CREATE TEMPORARY TABLE jl_dept_multi_tot_by_gender_age
SELECT 
	jl_dept_level, gender, age_group, tot_emp,
    SUM(tot_emp) OVER (PARTITION BY jl_dept_level) AS grand_total,
    SUM(tot_emp) OVER (PARTITION BY jl_dept_level, age_group) AS sub_grand_total
FROM jl_dept_by_gender_age
GROUP BY 1, 2, 3
ORDER BY 5 DESC, 3 

-- STEP 3: Divide tot_emp by sub_grand_total to get pct breakdown
SELECT 
	jl_dept_level, gender, age_group, tot_emp, sub_grand_total AS age_group_total,
    CONCAT(ROUND((tot_emp / sub_grand_total)*100,2), "%") AS pct_of_age_group_total
    , grand_total AS jl_dept_total
    , CONCAT(ROUND((tot_emp / grand_total)*100,2), "%") AS pct_of_jl_dept_total
FROM jl_dept_multi_tot_by_gender_age
													  
-- Hiring trend for all departments (no job level)
select*from divdata;
alter table divdata rename column `Employee ID` to emp_id;
alter table divdata rename column `Department @01.07.2020` to fy20_07_01_dept;
SELECT YEAR(`Last hire date`) AS yr,
COUNT(CASE WHEN fy20_07_01_dept = "Finance" THEN emp_id END) AS fi_hires,
COUNT(CASE WHEN fy20_07_01_dept = "HR" THEN emp_id END) AS hr_hires,
COUNT(CASE WHEN fy20_07_01_dept = "Internal Services" THEN emp_id END) AS is_hires,
COUNT(CASE WHEN fy20_07_01_dept = "Operations" THEN emp_id END) AS ops_hires,
COUNT(CASE WHEN fy20_07_01_dept= "Sales & Marketing" THEN emp_id END) AS sam_hires,
COUNT(CASE WHEN fy20_07_01_dept = "Strategy" THEN emp_id END) AS strat_hires
FROM divdata GROUP BY 1 ORDER BY 1;

-- Hiring trend for jl dept level that includes leavers in internal services & sales + marketing 
SELECT
	YEAR(`Last hire date`) AS yr,
    COUNT(CASE WHEN fy20_07_01_dept = "Finance" THEN emp_id END) AS fi_hires,
    COUNT(CASE WHEN fy20_07_01_dept = "HR" THEN emp_id END) AS hr_hires,
    COUNT(CASE WHEN fy20_07_01_dept = "Internal Services" THEN emp_id END) AS is_hires,
    COUNT(CASE WHEN fy20_07_01_dept = "Operations" THEN emp_id END) AS ops_hires,
    COUNT(CASE WHEN fy20_07_01_dept = "Sales & Marketing" THEN emp_id END) AS sam_hires,
    COUNT(CASE WHEN fy20_07_01_dept = "Strategy" THEN emp_id END) AS strat_hires
FROM divdata
GROUP BY 1
ORDER BY 1;  				

-- Hiring trend for internal services & sales + marketing at the jl dept level that includes FY20 leavers 
-- Leavers are included because we're looking at historical hiring trends & not employees that are still actively employed within the org
alter table divdata rename column `Job Level after FY20 promotions` to fy20_jl_aft_promo;
SELECT 
	YEAR(`Last hire date`) AS yr,
    -- COUNT(CASE WHEN fy20_07_01_dept = "Sales & Marketing" AND fy20_jl_aft_promo = "6 - Junior Officer" THEN de.emp_id END) AS sam_j_hires,
    COUNT(CASE WHEN fy20_07_01_dept = "Sales & Marketing" AND fy20_jl_aft_promo = "5 - Senior Officer" THEN de.emp_id END) AS sam_sn_hires,
    COUNT(CASE WHEN fy20_07_01_dept = "Sales & Marketing" AND fy20_jl_aft_promo = "4 - Manager" THEN de.emp_id END) AS sam_mngr_hires,
    COUNT(CASE WHEN fy20_07_01_dept = "Sales & Marketing" AND fy20_jl_aft_promo = "3 - Senior Manager" THEN de.emp_id END) AS sam_sn_mngr_hires,
    COUNT(CASE WHEN fy20_07_01_dept = "Sales & Marketing" AND fy20_jl_aft_promo = "2 - Director" THEN de.emp_id END) AS sam_dir_hires,
    COUNT(CASE WHEN fy20_07_01_dept = "Sales & Marketing" AND fy20_jl_aft_promo = "1 - Executive" THEN de.emp_id END) AS sam_exec_hires,
    COUNT(CASE WHEN fy20_07_01_dept = "Internal Services" AND fy20_jl_aft_promo = "6 - Junior Officer" THEN de.emp_id END) AS is_j_hires,
    COUNT(CASE WHEN fy20_07_01_dept = "Internal Services" AND fy20_jl_aft_promo = "5 - Senior Officer" THEN de.emp_id END) AS is_sn_hires,
    COUNT(CASE WHEN fy20_07_01_dept = "Internal Services" AND fy20_jl_aft_promo = "4 - Manager" THEN de.emp_id END) AS is_mngr_hires,
    COUNT(CASE WHEN fy20_07_01_dept = "Internal Services" AND fy20_jl_aft_promo = "3 - Senior Manager" THEN de.emp_id END) AS is_sn_mngr_hires,
    COUNT(CASE WHEN fy20_07_01_dept = "Internal Services" AND fy20_jl_aft_promo = "2 - Director" THEN de.emp_id END) AS is_dir_hires,
    COUNT(CASE WHEN fy20_07_01_dept = "Internal Services" AND fy20_jl_aft_promo = "1 - Executive" THEN de.emp_id END) AS is_exec_hires
FROM divdata as de
	LEFT JOIN fact_table f
		ON f.EmpID = de.emp_id
WHERE fy20_07_01_dept IN ("Sales & Marketing", "Internal Services")
GROUP BY 1
ORDER BY 1;													

-- Gender hiring trend for 3 - Senior Manager in Sales & Marketing
SELECT 
	YEAR(`Last hire date`) AS yr
    , COUNT(CASE WHEN fy20_07_01_dept = "Sales & Marketing" AND fy20_jl_aft_promo = "3 - Senior Manager" THEN de.emp_id END) AS total_sam_sn_mngr_hires
    , COUNT(CASE WHEN Gender = "M" AND fy20_07_01_dept = "Sales & Marketing" AND fy20_jl_aft_promo = "3 - Senior Manager" THEN de.emp_id END) AS male_hires
    , COUNT(CASE WHEN Gender = "F" AND fy20_07_01_dept = "Sales & Marketing" AND fy20_jl_aft_promo = "3 - Senior Manager" THEN de.emp_id END) AS female_hires
FROM divdata de
	LEFT JOIN fact_table f
		ON f.EmpID = de.emp_id
WHERE fy20_07_01_dept IN ("Sales & Marketing", "Internal Services")
GROUP BY 1
ORDER BY 1;
-- Gender hiring trend for 3 - Senior Manager in Internal Services
SELECT 
	YEAR(`Last hire date`) AS yr
    , COUNT(CASE WHEN fy20_07_01_dept = "Internal Services" AND fy20_jl_aft_promo = "3 - Senior Manager" THEN de.emp_id END) AS total_is_sn_mngr_hires
    , COUNT(CASE WHEN gender = "M" AND fy20_07_01_dept = "Internal Services" AND fy20_jl_aft_promo = "3 - Senior Manager" THEN de.emp_id END) AS male_hires
    , COUNT(CASE WHEN gender = "F" AND fy20_07_01_dept = "Internal Services" AND fy20_jl_aft_promo = "3 - Senior Manager" THEN de.emp_id END) AS female_hires
FROM divdata de
	LEFT JOIN fact_table f
		ON f.EmpID = de.emp_id
WHERE fy20_07_01_dept IN ("Sales & Marketing", "Internal Services")
GROUP BY 1
ORDER BY 1;
-- Gender hiring trend for 4 - Manager in Sales & Marketing
SELECT 
	YEAR(`Last hire date`) AS yr
    , COUNT(CASE WHEN fy20_07_01_dept = "Sales & Marketing" AND fy20_jl_aft_promo = "4 - Manager" THEN de.emp_id END) AS total_sam_mngr_hires
    , COUNT(CASE WHEN gender = "M" AND fy20_07_01_dept = "Sales & Marketing" AND fy20_jl_aft_promo = "4 - Manager" THEN de.emp_id END) AS male_hires
    , COUNT(CASE WHEN gender = "F" AND fy20_07_01_dept = "Sales & Marketing" AND fy20_jl_aft_promo = "4 - Manager" THEN de.emp_id END) AS female_hires
FROM divdata as de
	LEFT JOIN fact_table f
		ON f.EmpID = de.emp_id
WHERE fy20_07_01_dept IN ("Sales & Marketing", "Internal Services")
GROUP BY 1
ORDER BY 1 																	