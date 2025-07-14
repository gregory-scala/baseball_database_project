/*Creating a view that Gets yearly offensive stats for players since 1901 by team and positoin.*/

IF OBJECT_ID('dbo.vw_YearlyBattingStats', 'V') IS NOT NULL
    DROP VIEW dbo.vw_YearlyBattingStats;
GO

CREATE VIEW dbo.vw_YearlyBattingStats AS

WITH DUPLICATES_TABLE AS (
SELECT
	b.playerID,
	b.yearID,
	count(*) as multiple_flag
FROM 
	lahman2023.dbo.Batting as b
JOIN 
	lahman2023.dbo.vw_PlayerInfo as pi
ON
	pi.playerID = b.playerID
GROUP BY
	b.playerID,
	b.yearID
),

TEAM_ID AS (
SELECT DISTINCT
	b.playerID,
	b.yearID,
	CASE
		WHEN dt.multiple_flag = 1 THEN b.teamID
		ELSE 'MLT'
	END AS teamID
FROM
	lahman2023.dbo.Batting as b
JOIN
	DUPLICATES_TABLE as dt
ON
	dt.playerID = b.playerID AND dt.yearID = b.yearID
),

/* Sum the numbers for players that play for multiple teams in a season */
RAW_NUMBERS AS (
SELECT
	position.Name,
	b.playerID,
	b.yearID,
	ti.teamID,
	position.Primary_Position as POS,
	SUM(b.G) as G,
	SUM(b.AB) as AB,
	SUM(b.R) as R,
	SUM(b.H) as H,
	SUM(b.[2B]) as [2B],
	SUM(b.[3B]) as [3B],
	SUM(b.HR) as HR,
	SUM(b.RBI) as RBI,
	SUM(b.SB) as SB,
	SUM(b.CS) as CS,
	SUM(b.BB) as BB,
	SUM(b.HBP) as HBP,
	SUM(b.SH) as SH,
	SUM(b.SF) as SF,
	SUM(b.GIDP) as GIDP
FROM
	lahman2023.dbo.Batting as b
JOIN
	lahman2023.dbo.vw_PRIMARYPOSITION_YEAR as position
ON
	position.yearID = b.yearID AND position.playerID = b.playerID
JOIN
	TEAM_ID AS ti
ON
	ti.playerID = b.playerID AND ti.yearID = b.yearID
GROUP BY
	b.playerID, b.yearID, position.Name, position.Primary_Position, ti.teamID
HAVING
	SUM(b.[AB]) > 0
),

/* Calculating number of singles a player has */
SINGLES_DATA AS (
SELECT
	b.playerID,
	b.yearID,
	(b.H - b.[2B]-b.[3B]) AS [1B]
FROM	
	RAW_NUMBERS as b
),

/* Calculate Batting Average, On Base Percentage, and Slugging Percentage */
PERCENTAGES_1 AS (
SELECT
	b.playerID,
	b.yearID,
	b.POS,
	CAST(1.0*b.H/b.AB as DECIMAL(4,3)) as BA,
	CASE
		WHEN b.yearID > 1953
		THEN
			CAST(1.0*(b.H + b.BB + b.HBP) /(b.AB+ b.BB + b.HBP + b.SH + b.SF) as DECIMAL(4,3))
		ELSE
			CAST(1.0*(b.H + b.BB + b.HBP) /(b.AB+ b.BB + b.HBP + b.SH) as DECIMAL(4,3))
	END AS OBP,
	CAST(1.0*(s.[1b] + (2*b.[2B]) + (3*b.[3B]) + (4*b.[HR])) /(b.AB) as DECIMAL(4,3)) as SLG
FROM
	RAW_NUMBERS as b
JOIN
	SINGLES_DATA as s 
ON
	s.playerID = b.playerID AND s.yearID = b.yearID
),

/*Creating OPS */
OPS_Stats AS (
SELECT
	b.playerID,
	b.yearID,
	b.OBP + b.SLG AS OPS
FROM
	PERCENTAGES_1 as b),

PERCENTAGES_2 AS (
SELECT
	b.playerID,
	b.yearID,
	b.BA,
	b.OBP,
	b.SLG,
	o.OPS
FROM
	PERCENTAGES_1 as b
JOIN
	OPS_Stats as o
ON
	b.playerID = o.playerID AND b.yearID = o.yearID
)

/* Creating a table with all of the stats together, starting from the modern era (since 1901) */
SELECT
	r.Name,
	r.playerID,
	r.yearID,
	r.teamID,
	r.POS,
	r.G,
	r.AB,
	p.BA,
	p.OBP,
	p.SLG,
	p.OPS,
	r.R,
	r.H,
	r.[2B],
	r.[3B],
	r.HR,
	r.RBI,
	r.SB,
	r.CS,
	r.BB,
	r.HBP,
	r.SH,
	r.SF,
	r.GIDP
FROM
	RAW_NUMBERS as r
JOIN
	PERCENTAGES_2 as p
ON
	p.playerID = r.playerID AND p.yearID = r.yearID
WHERE
	r.yearID >= 1901