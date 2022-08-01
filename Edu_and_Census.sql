--Explore tables separately
--How many public schools are in each zip code?
SELECT zip_code, COUNT(*) as 'Number of Schools'
FROM public_hs_data
GROUP BY zip_code
ORDER BY 1;

--How many public schools are in each state?
SELECT state_code, COUNT(*) as 'Number of schools'
FROM public_hs_data
GROUP BY state_code
ORDER BY 1;

--locale_code corresponds to various levels of urbanization. 
--Use case statements to display the corresponding locale_text and locale_size.

SELECT city, state_code, locale_code, 
CASE substr(locale_code, 1, 1)
	WHEN '1' THEN 'City'
	WHEN '2' THEN 'Suburb'
	WHEN '3' THEN 'Town'
	WHEN '4' THEN 'Rural'
END AS Urbanization,

CASE 
	WHEN locale_code <= 23 THEN
		CASE substr(locale_code, 2, 1)
			WHEN '1' THEN 'Large'
			WHEN '2' THEN 'Midsize'
			WHEN '3' THEN 'Small'
		END
	ELSE 
		CASE substr(locale_code, 2, 1)
			WHEN '1' THEN 'Fringe'
			WHEN '2' THEN 'Distant'
			WHEN '3' THEN 'Remote'
		END
END AS Size
FROM public_hs_data
ORDER BY 2;

--What was the minimum, maximum, and average median_household_income of the nation?
SELECT 
	ROUND(MIN(median_household_income),2) AS 'Minimum Median Income', 
	ROUND(MAX(median_household_income),2) AS 'Maximum Median Income',
	ROUND(AVG(median_household_income),2) AS 'Average Median Income'
FROM census_data
WHERE median_household_income != 'NULL';

--What was the minimum, maximum, and average median_household_income of each state?
SELECT state_code AS 'State',
	ROUND(MIN(median_household_income),2) AS 'Minimum Median Income', 
	ROUND(MAX(median_household_income),2) AS 'Maximum Median Income',
	ROUND(AVG(median_household_income),2) AS 'Average Median Income'
FROM census_data
WHERE median_household_income != 'NULL'
GROUP BY state_code
ORDER BY 1;

--Do characteristics like income influence performance in school?
SELECT 
	CASE 
		WHEN median_household_income < 50000 THEN '$0-$50'
		WHEN median_household_income BETWEEN 50000 AND 100000 THEN '$50-$100'
		WHEN median_household_income > 100000 THEN '>$100'
		ELSE 'NA'
	END AS 'Income',
	ROUND(AVG(pct_proficient_math),1) as 'Math Proficiency Percentage', 
	ROUND(AVG(pct_proficient_reading),1) AS 'Reading Proficiency Percentage'
FROM public_hs_data as hs
JOIN census_data as c
ON hs.zip_code = c.zip_code
WHERE median_household_income != 'NULL'
GROUP BY 1
ORDER BY 1; 

--On average, do students do better on the math or reading exam?
WITH versus AS(
SELECT 
	state_code, 
	ROUND(AVG(pct_proficient_math),1) AS 'MathProficiency', 
	ROUND(AVG(pct_proficient_reading),1) AS 'ReadingProficiency', 
	CASE
		WHEN AVG(pct_proficient_math) < AVG(pct_proficient_reading) THEN 'Reading'
		WHEN AVG(pct_proficient_math) > AVG(pct_proficient_reading) THEN 'Math'
		ELSE 'No Exam Data'
	END AS 'WhichIsHigher'
FROM public_hs_data
GROUP BY 1
)

SELECT versus.WhichIsHigher, COUNT(public_hs_data.state_code) AS 'NumOfStates'
FROM versus
JOIN public_hs_data
ON versus.state_code = public_hs_data.state_code
GROUP BY 1
ORDER BY 2 DESC;

--What is the average proficiency on state assessment exams for each zip code,
--And how do they compare to other zip codes in the same state?
WITH state_stats AS(
SELECT 
	state_code AS 'State',
	ROUND(AVG(pct_proficient_math),1) AS 'AvgMath',
	ROUND(AVG(pct_proficient_reading),1) AS 'AvgReading'
FROM public_hs_data
WHERE pct_proficient_math != 'NULL' AND pct_proficient_reading != 'NULL'
GROUP BY 1
)

SELECT 
	state_stats.State, 
	public_hs_data.zip_code, 
	state_stats.AvgMath AS 'Math Avg by State',
	ROUND(AVG(pct_proficient_math),1) AS 'Math Avg by Zip',
	state_stats.AvgReading AS 'Reading Avg by State',
	ROUND(AVG(pct_proficient_reading),1) AS 'Reading Avg by Zip'
FROM state_stats
JOIN public_hs_data
ON state_stats.State = public_hs_data.state_code
GROUP BY 2
ORDER BY 1, 2;