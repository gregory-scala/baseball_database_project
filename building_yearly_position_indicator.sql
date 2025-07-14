/*Create View to Assign a primary position to a player by each year they played*/
/* Note the Lahman Database only started trackibg soecu */

IF OBJECT_ID('dbo.vw_PrimaryPosition_Year', 'V') IS NOT NULL
    DROP VIEW dbo.vw_PrimaryPosition_Year;
GO

CREATE VIEW dbo.vw_PrimaryPosition_Year AS

/* Calculate the total number of games played by a player in a year */
WITH GamesInfo AS (
SELECT
	b.playerID,
	pi.Name,
	b.yearID,
	sum(b.G) as "Games"
FROM
	lahman2023.dbo.Batting as b
JOIN
	lahman2023.dbo.vw_PlayerInfo as pi
ON
	pi.playerID = b.playerID
GROUP BY
	b.playerID, b.yearID, pi.Name),


/* Calculating the total number of games played for each outfield position for each player who played at least one game in the outfield.
This takes into account that different outfield positions are stored in separate tables, and the information is stored separately
before and after 1954.*/
OF_Positions AS (
SELECT
	f.playerID,
	f.yearID,
	f.Glf AS "LF_Games",
	f.Gcf AS "CF_Games",
	f.Grf AS "RF_Games"
FROM
	lahman2023.dbo.FieldingOF as f
WHERE f.yearID < 1954

UNION

SELECT
	f.playerID,
	f.yearID,
	SUM(CASE WHEN f.POS = 'LF' THEN f.G ELSE 0 END) AS "LF_Games",
	SUM(CASE WHEN f.POS = 'CF' THEN f.G ELSE 0 END) AS "CF_Games",
	SUM(CASE WHEN f.POS = 'RF' THEN f.G ELSE 0 END) AS "RF_Games"
FROM
	lahman2023.dbo.FieldingOFsplit as f
WHERE
	f.yearID >= 1954
GROUP BY
	f.playerID, f.yearID
),
/* Calculating the total number of games played for each non-outfield position. */
PositionInfo_year2 AS (
SELECT
	gi.Name,
	f.playerID,
	f.yearID,
	MAX(gi.Games) as "Total Games",
	SUM(CASE WHEN f.POS = '1B' THEN f.G ELSE 0 END) AS "1B_Games",
	SUM(CASE WHEN f.POS = '2B' THEN f.G ELSE 0 END) AS "2B_Games",
	SUM(CASE WHEN f.POS = '3B' THEN f.G ELSE 0 END) AS "3B_Games",
	SUM(CASE WHEN f.POS = 'SS' THEN f.G ELSE 0 END) AS "SS_Games",
	SUM(CASE WHEN f.POS = 'OF' THEN f.G ELSE 0 END) AS "OF_Games",
	SUM(CASE WHEN f.POS = 'C' THEN f.G ELSE 0 END) AS "C_Games",
	SUM(CASE WHEN f.POS = 'P' THEN f.G ELSE 0 END) AS "P_Games"
FROM
	lahman2023.dbo.Fielding as f
JOIN
	GamesInfo AS gi
ON
	gi.playerID = f.playerID AND gi.yearID = f.yearID
GROUP BY
	f.playerID, f.yearID, gi.Name
),

/*Combining all of the information to create the total number of games played in each position per year.
Here, since the outfield data only contains information on players who played at least one game in the outfield. */
PositionInfo_year AS (
SELECT
	pi.Name,
	pi.playerID,
	pi.yearID,
	pi.[Total Games],
	pi.[1B_Games],
	pi.[2B_Games],
	pi.[3B_Games],
	pi.[SS_Games],
	pi.[OF_Games],
	COALESCE(outfield.[LF_Games], 0) AS "LF_Games",
	COALESCE(outfield.[CF_Games], 0) AS "CF_Games",
	COALESCE(outfield.[RF_Games], 0) AS "RF_Games",
	pi.[C_Games],
	pi.[P_Games]
FROM
	PositionInfo_year2 as pi
LEFT OUTER JOIN
	OF_Positions as outfield
ON
	pi.yearID = outfield.yearID AND pi.playerID = outfield.playerID 
),

/* Find a baseball player's primary position */

PRIMARY_POSITION_YEAR AS (
SELECT
	Name,
	playerID,
	yearID,
	CASE
		WHEN "1B_Games" >= "2B_Games"
		AND "1B_Games" >= "3B_Games"
		AND "1B_Games" >= "SS_Games"
		AND "1B_Games" >= "LF_Games"
		AND "1B_Games" >= "CF_Games"
		AND "1B_Games" >= "RF_Games"
		AND "1B_Games" >= "C_Games"
		AND "1B_Games" >= "P_Games"
		THEN '1B'

		WHEN "2B_Games" >= "1B_Games"
		AND "2B_Games" >= "3B_Games"
		AND "2B_Games" >= "SS_Games"
		AND "2B_Games" >= "LF_Games"
		AND "2B_Games" >= "CF_Games"
		AND "2B_Games" >= "RF_Games"
		AND "2B_Games" >= "C_Games"
		AND "2B_Games" >= "P_Games"
		THEN '2B'

		WHEN "3B_Games" >= "1B_Games"
		AND "3B_Games" >= "2B_Games"
		AND "3B_Games" >= "SS_Games"
		AND "3B_Games" >= "LF_Games"
		AND "3B_Games" >= "CF_Games"
		AND "3B_Games" >= "RF_Games"
		AND "3B_Games" >= "C_Games"
		AND "3B_Games" >= "P_Games"
		THEN '3B'

		WHEN "SS_Games" >= "1B_Games"
		AND "SS_Games" >= "2B_Games"
		AND "SS_Games" >= "3B_Games"
		AND "SS_Games" >= "LF_Games"
		AND "SS_Games" >= "CF_Games"
		AND "SS_Games" >= "RF_Games"
		AND "SS_Games" >= "C_Games"
		AND "SS_Games" >= "P_Games"
		THEN 'SS'

		WHEN "LF_Games" >= "1B_Games"
		AND "LF_Games" >= "2B_Games"
		AND "LF_Games" >= "3B_Games"
		AND "LF_Games" >= "SS_Games"
		AND "LF_Games" >= "CF_Games"
		AND "LF_Games" >= "RF_Games"
		AND "LF_Games" >= "C_Games"
		AND "LF_Games" >= "P_Games"
		THEN 'LF'

		WHEN "CF_Games" >= "1B_Games"
		AND "CF_Games" >= "2B_Games"
		AND "CF_Games" >= "3B_Games"
		AND "CF_Games" >= "SS_Games"
		AND "CF_Games" >= "LF_Games"
		AND "CF_Games" >= "RF_Games"
		AND "CF_Games" >= "C_Games"
		AND "CF_Games" >= "P_Games"
		THEN 'CF'

		WHEN "RF_Games" >= "1B_Games"
		AND "RF_Games" >= "2B_Games"
		AND "RF_Games" >= "3B_Games"
		AND "RF_Games" >= "SS_Games"
		AND "RF_Games" >= "LF_Games"
		AND "RF_Games" >= "CF_Games"
		AND "RF_Games" >= "C_Games"
		AND "RF_Games" >= "P_Games"
		THEN 'RF'

		
		WHEN "C_Games" >= "1B_Games"
		AND "C_Games" >= "3B_Games"
		AND "C_Games" >= "2B_Games"
		AND "C_Games" >= "SS_Games"
		AND "C_Games" >= "LF_Games"
		AND "C_Games" >= "CF_Games"
		AND "C_Games" >= "RF_Games"
		AND "C_Games" >= "P_Games"
		THEN 'C'

		WHEN "P_Games" >= "1B_Games"
		AND "P_Games" >= "3B_Games"
		AND "P_Games" >= "2B_Games"
		AND "P_Games" >= "SS_Games"
		AND "P_Games" >= "LF_Games"
		AND "P_Games" >= "CF_Games"
		AND "P_Games" >= "RF_Games"
		AND "P_Games" >= "C_Games"
		THEN 'P'

		ELSE 'N/A'
	END AS 'Primary_Position'
FROM
	PositionInfo_year
)

SELECT
	*
FROM
	PRIMARY_POSITION_YEAR