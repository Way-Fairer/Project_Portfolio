-- Source:
-- 4 Excel sheets named "test", "result", "sample", and "location" that provide environmental data on superfund site. Excel sheets imported into SSMS as separate databases.

-- Tasks:
-- Write a SQL query that brings together the four data tables provided into a single flat file that could be used for data analysis. 
  -- Include a result column that contains a numeric value for all records. Non-detected results (detect_flag = N) should be presented as the quantitation limit.
  -- Include a binary field called detect_num based on the character field detect_flag, that can be used to summarize the number of detections (detect_flag = Y) during subsequent data analysis.
  -- All result concentrations should be reported in milligrams per kilogram (mg/kg), where possible.
  -- Depth interval categories should be assigned as follows:
    -- Surficial (<=0.20m Start Depth)
    -- Shallow Sub-Surface (0.20-1.00m Start Depth)
-- Write an UPDATE statement to increase the analysis_date by one day for all results associated with location AA001.


-- See separate preprocessing notes .sql file for additional .sql code performed and notes on assumptions and inconsistencies.

-- UPDATE statement to increase the analysis_date by one day for all results associated with location AA001
-- Prior to performing update to table, performed SELECT query listed first below to ensure UPDATE statement would only affect appropriate rows. 
-- *Note: UPDATE statement uses DATEADD() function that is specific to SQL Server Management Studio (SSMS)/Transact-SQL (T-SQL).
SELECT 
	analysis_date, 
	sys_sample_code
FROM 
	kendell_superfund.dbo.test
WHERE 
	sys_sample_code LIKE '%AA001%'
;
UPDATE 
	kendell_superfund.dbo.test
SET 
	analysis_date = DATEADD(d,1,analysis_date)
WHERE
	sys_sample_code LIKE '%AA001%'
;
-- Query to pull data from all columns in four provided tables for Task 1 Deliverable requirements
SELECT
	r.TestID,
	t.analytic_method,
	t.MethodGroup,
	t.fraction,
	t.analysis_date,
	r.chemical_name,
	r.cas_rn,
	-- Convert numeric results to mg/kg, except in case of pH results with results reported in SU (unable to convert from SU).
	(CASE
		WHEN r.result_unit = '%' AND r.result_numeric IS NOT NULL THEN (r.result_numeric * 10000)
		WHEN r.result_unit = 'ug/kg' AND r.result_numeric IS NOT NULL THEN (r.result_numeric / 1000)
		WHEN r.result_unit = 'mg/kg' AND r.result_numeric IS NOT NULL THEN r.result_numeric
		WHEN r.result_unit = 'SU' AND r.result_numeric IS NOT NULL THEN r.result_numeric
		WHEN r.result_numeric IS NULL THEN r.quantitation_limit
	END) AS updated_result_num,
	-- Convert result units to mg/kg, except in case of pH results with results reported in SU (unable to convert from SU).
	(CASE 
		WHEN r.result_unit = 'SU' THEN 'SU'
		ELSE 'mg/kg'
	END) as updated_result_unit,
	-- Create binary field called detect_num based on the character field detect_flag.
	(CASE
		WHEN r.detect_flag = 'Y' THEN 1
		WHEN r.detect_flag = 'N' THEN 0
	END) AS detect_num,
	r.interpreted_qualifiers,
	-- Quantitation limit and units were left as-is, and not converted to mg/kg as they are for informational purposes only.
	r.quantitation_limit,
	r.detection_limit_unit,
	-- Create depth interval field assigned as  follows: Surficial (<=0.20m Start Depth) and Shallow Sub-Surface (0.20-1.00m Start Depth).
	(CASE
		WHEN s.start_depth <= 0.20 THEN 'Surficial'
		WHEN s.start_depth BETWEEN 0.20 AND 1.00 THEN 'Shallow Sub-Surface'
	END) AS depth_interval,
	l.sys_loc_code,
	l.loc_type,
	s.sys_sample_code,
	s.sample_name,
	s.SampleType,
	s.Matrix,
	s.sample_date,
	s.start_depth,
	s.end_depth,
	s.depth_unit AS sample_depth_unit,
	l.x_coord,
	l.y_coord,
	l.coord_type_code,
	l.Exposure_Area
FROM 
	kendell_superfund.dbo.result AS r
LEFT JOIN kendell_superfund.dbo.test AS t
	ON r.TestID = t.TestID
LEFT JOIN kendell_superfund.dbo.sample AS s
	ON s.sys_sample_code = t.sys_sample_code
LEFT JOIN kendell_superfund.dbo.location AS l
	ON s.sys_loc_code = l.sys_loc_code
;
