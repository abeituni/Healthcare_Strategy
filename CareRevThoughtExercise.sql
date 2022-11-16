--Creating Table for Florida Shift History
CREATE TABLE florida_shift_history (
	professional_id INT NOT NULL,
	position_ids VARCHAR NOT NULL,
	shift_start_start_time timestamp,
	shift_end_time timestamp,
	name VARCHAR NOT NULL,
	report_grouping_region_code VARCHAR NOT NULL,
	facility_rate_cents_per_hour INT NOT NULL,
	professional_rate_cents_per_hour INT NOT NULL,
	canceled_reason INT
	);

--Check table after importing data
Select * from florida_shift_history

-- QUESTION 1
	-- 1) After analyzing the history of Florida shift data, there are a few key data points to take into account.
		-- RN: The average rate for RNs was 9478 cents per hour. The most common (mode) rate for these RNs was 9750, with a rate of 10075 trailing closely, accounting for 25% of shifts). If this facility would like to be competitive, I would recommend at or above a rate of 10100 cents per hour for RNs which equates to 6.2% over the average rate.
		-- CNA: The average rate for CNAs was 2309 cents per hour. The most common (mode) rate for these CNAs was 2310, accounting for 45% of shifts. If this facility would like to be competitive, I would recommend a rate at or above 2425 cents per hour for CNAs, which equates to 5% over the average & most common rate.
		-- TECH: The average rate for TECHs was 1940 cents per hour. The most common (mode) rate for these CNAs was 2000, accounting for 83% of shifts. If this facility would like to be competitive, I would recommend a rate at or above 2100 cents per hour for TECHs, which equates to 5% over the most common rate.
	-- 2) After analyzing the Facility rates for each Position, there were a few key data points to consider. We must take into account the potential rate increase for each position and if we want to keep CareRev profits in line with past history, we should reflect an increase in facility billing as well.
		-- RN: The average facility rate for RNs was 11184 cents per hour. The two most common (mode) rates for RNs were 12188 & 12594 (26% of shifts). I would recommned a minimum billing rate of 12000 cents per hour, which is a 7% increase from previous average rates.
		-- CNA: The average facility rate for CNAs was 3296 cents per hour. The most common (mode) rate for CNAs was 3300 cents per hour. I would reccomend a rate of at least 3465 to bill the facility, a 5% increase from our average rate. 
		-- Tech: The average facility rate for TECHs was 2771 cents per hour. The most common (mode) rate for TECHS was 2857 cents per hour. I would recommend a rate of 2909 cents per hour when billing the facility, which is a 5% increase from our average rate. If we'd like to be competitive, we can consider dropping that rate to 2860, which was our most common historical rate.

--Number of RNs shifts scheduled in data (not excluding cancellations)
Select count(position_ids) from florida_shift_history
where position_ids = 'RN'
--Number of CNAs shifts scheduled in data (not excluding cancellations)
Select count(position_ids) from florida_shift_history
where position_ids = 'CNA'
--Number of Techs shifts scheduled in data (not excluding cancellations)
Select count(position_ids) from florida_shift_history
where position_ids = 'TECH'

--Query to find Avg Rate (Cents per hour) For each Position & Facility (not excluding cancellations)
Select position_ids, AVG(professional_rate_cents_per_hour) as "Average Professional Rate (Cents Per Hour)", AVG(facility_rate_cents_per_hour) as "Average Facility Rate (Cents Per Hour)"
From florida_shift_history
Group by position_ids;

-- Mode for Professional Rates (not excluding cancellations)
Select position_ids, professional_rate_cents_per_hour AS mode_professional_rate, Count(*) AS total
From florida_shift_history
Group by 1,2
Order by total DESC, mode_professional_rate DESC

--Mode for Facility Rates (not excluding cancellations)
Select position_ids, facility_rate_cents_per_hour AS mode_facility_rate, Count(*) AS total
From florida_shift_history
Group by 1,2
Order by total DESC, mode_facility_rate DESC
	
-- Create Cancellation Reason Key Table
CREATE TABLE cancellation_key (
	reason_code INT,
	reason VARCHAR,
	notes_about_this_reason TEXT
	);

-- Check table after importing data
Select * from cancellation_key

-- Question 2
	-- 1) After analyzing the data, a staggering 56% (1142) of cancellations were due to the Facility cancelling a shift for a number of reasons. The primary reason was a lack of need for coverage, which accounted for 26% (555) of all cancellations. I would recommned facilities & managers do a better job of forecasting personal needed in order to to cut down on these cancellations. 
	-- 2) 16% (335) of cancellations were because Professionals canceled with a reason of 'Other'. If we want to address that, I recommend we potentially remove the Other option and give Professionals an option for some sort of short answer or dig a little deeper on what the 'Other' option could entail.

-- Join existing tables
Create Table cancellations as (
	Select florida_shift_history.professional_id, cancellation_key.reason_code, cancellation_key.reason, florida_shift_history.position_ids, cancellation_key.notes_about_this_reason
	From cancellation_key
	INNER JOIN florida_shift_history
	ON cancellation_key.reason_code = florida_shift_history.canceled_reason
	);

--Check Table Data
Select * from cancellations

--Total Number of Cancellations in Florida_Shift_History
Select count(reason_code) From Cancellations

--Query to discover cancellation totals and reasons in Florida_Shift_History
Select reason_code, count(reason_code) AS CountOf, reason, notes_about_this_reason 
From cancellations
Group by reason_code, reason, notes_about_this_reason
Order By CountOf DESC;

-- Question 3
	-- There are currently 358 Professionals in the area that worked a total of 2974 (non-cancelled) shifts in the span of 11 months throughout 10 different facilities. That leaves us with an average of a little over 8 shifts worked per Professional. Based off our current findings, if we were to open up 1000 expected posted shifts per month in this new facility i would recommend nearly tripling our pool of professionals to meet the influx of posted shifts. At a rate of 11000 extra shifts in an eleven month span, we'd anticpate about 6875 filled shifts. If we project professionals to work a little over 8 shifts in this time frame, our output shows we would need an estiamted 827 more Professionals to fill this gap.

--Count of professionals picking up shifts in area facilities
Select count(distinct professional_id) as Total_count
From florida_shift_history

--Number of shifts worked at each facility
Select name, count(name) as Total_count
From florida_shift_history
Group by name
Order by Total_count DESC

-- Find the total number of Non-Canceled Shifts
Select count(position_ids) as Worked_Shifts
From florida_shift_history
Where canceled_reason IS Null

--Find first & last shifts worked in data to get a date range on dataset
Select min(shift_start_start_time) as First, max(shift_start_start_time) as Last from florida_shift_history
	
-- Question 4
	-- Another dataset I think could be useful throughout this exercise would be Professional work schedules & availability. It is a little difficult to accurately recommend expanding the Professional Pool in Question 3 without seeing all the information. In addition, In Question #3, the prompt says we fullfil 50-75% of posted shifts. I'd like to look at previous years posting data to see what the actual rate of fullfillment is for all postings & facilities. I'd also be interested in looking at facility scheduling which would help us get a better understanding as to why Facilities are so frequently cancelling.

-- Bonus Question (Find the first 50 canceled CNA Shifts)
Select * from florida_shift_history
Where position_ids = 'CNA' AND canceled_reason is NOT NULL
Limit 50;
	
