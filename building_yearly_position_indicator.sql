/*Create View to Assign a primary position to a player by year.*/

IF OBJECT_ID('dbo.vw_PrimaryPosition_Year', 'V') IS NOT NULL
    DROP VIEW dbo.vw_PrimaryPosition_Year;
GO

CREATE VIEW dbo.vw_PrimaryPosition_Year AS

/* Calculate the total number of games played by a player in a year.*/
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

/* Calculating the total number of games played by position in a year. */
Aggregated_Positions AS (
SELECT
	f.playerID,
	f.yearID,
	f.POS,
	sum(f.G) as G
FROM
	lahman2023.dbo.Fielding as f
GROUP BY
	f.playerID, f.yearID, f.POS
),

/*Adjusting the above cte to create a column for games played by each position. */
PositionInfo_year AS (
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
	Aggregated_Positions as f
JOIN
	GamesInfo AS gi
ON
	gi.playerID = f.playerID AND gi.yearID = f.yearID
GROUP BY
	f.playerID, f.yearID, gi.Name
),

/* Finding a baseball player's primary position */

PRIMARY_POSITION_YEAR AS (
SELECT
	Name,
	playerID,
	yearID,
	CASE
		WHEN "1B_Games" >= "2B_Games"
		AND "1B_Games" >= "3B_Games"
		AND "1B_Games" >= "SS_Games"
		AND "1B_Games" >= "OF_Games"
		AND "1B_Games" >= "C_Games"
		AND "1B_Games" >= "P_Games"
		THEN '1B'

		WHEN "2B_Games" >= "1B_Games"
		AND "2B_Games" >= "3B_Games"
		AND "2B_Games" >= "SS_Games"
		AND "2B_Games" >= "OF_Games"
		AND "2B_Games" >= "C_Games"
		AND "2B_Games" >= "P_Games"
		THEN '2B'

		WHEN "3B_Games" >= "1B_Games"
		AND "3B_Games" >= "2B_Games"
		AND "3B_Games" >= "SS_Games"
		AND "3B_Games" >= "OF_Games"
		AND "3B_Games" >= "C_Games"
		AND "3B_Games" >= "P_Games"
		THEN '3B'

		WHEN "SS_Games" >= "1B_Games"
		AND "SS_Games" >= "2B_Games"
		AND "SS_Games" >= "3B_Games"
		AND "SS_Games" >= "OF_Games"
		AND "SS_Games" >= "C_Games"
		AND "SS_Games" >= "P_Games"
		THEN 'SS'

		WHEN "OF_Games" >= "1B_Games"
		AND "OF_Games" >= "2B_Games"
		AND "OF_Games" >= "3B_Games"
		AND "OF_Games" >= "SS_Games"
		AND "OF_Games" >= "C_Games"
		AND "OF_Games" >= "P_Games"
		THEN 'OF'

		
		WHEN "C_Games" >= "1B_Games"
		AND "C_Games" >= "2B_Games"
		AND "C_Games" >= "3B_Games"
		AND "C_Games" >= "SS_Games"
		AND "C_Games" >= "OF_Games"
		AND "C_Games" >= "P_Games"
		THEN 'C'

		WHEN "P_Games" >= "1B_Games"
		AND "P_Games" >= "2B_Games"
		AND "P_Games" >= "3B_Games"
		AND "P_Games" >= "SS_Games"
		AND "P_Games" >= "C_Games"
		AND "P_Games" >= "P_Games"
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