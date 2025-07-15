/* 
In this exercise, I calculate the number of three-tool players: players in the top quartile of batting average (hitting), slugging percentage (power), and speed (stolen bases)
by team. I identify a player as having a "tool" if it is in the top quartile in a particular category.
*/

/* Creating a cte that will be used later to match a teamID to a Franchise Name */
WITH team_franchise AS
(SELECT DISTINCT
	t.teamID,
	t.franchID,
	tf.franchName
FROM
	lahman2023.dbo.Teams as t
JOIN
	lahman2023.dbo.TeamsFranchises as tf
ON
	t.franchID = tf.franchID),

/* Taking into account that some players played on multiple teams, and that teamID WAS has two different franchise names, the Washington Nationals, and the Washingon Senators. */
YearlyStats_TeamName AS (
SELECT DISTINCT
	bs.teamID,
	bs.yearID,
	CASE
		WHEN bs.teamID = 'MLT' THEN 'Multiple Teams'
		WHEN bs.teamID = 'WAS' AND bs.yearID < 1980 THEN 'Washington Senators'
		WHEN bs.teamID = 'WAS' AND bs.yearID >= 1980 THEN 'Washington Nationals'
		ELSE tf.franchName
	END AS TeamName
FROM
	lahman2023.dbo.vw_YearlyBattingStats as bs
LEFT OUTER JOIN
	team_franchise as tf
ON
	bs.teamID = tf.teamID
),

/* Ranking players with over 300 at bats in a season by Batting Average (hitting), Slugging Percentage (power), and stolen bases (speed) and dividing them into four quartiles. */
YearlyStats_Qualified AS (
	SELECT bs.*,
	tn.TeamName,
	ntile(4) OVER (PARTITION BY bs.yearID
				ORDER BY SLG DESC) as "Power Quartile",
	ntile(4) OVER (PARTITION BY bs.yearID
				ORDER BY BA DESC) as "Hit Quartile",
	ntile(4) OVER (PARTITION BY bs.yearID
				ORDER BY SB DESC) as "Speed Quartile"
	FROM
		lahman2023.dbo.vw_YearlyBattingStats as bs
	JOIN
		YearlyStats_TeamName as tn
	ON
		tn.teamID = bs.teamID AND bs.yearID = tn.yearID
	WHERE
		AB > 300

)

SELECT
	ys.TeamName,
	SUM(CASE WHEN (ys.[Power Quartile] = 1 AND ys.[Hit Quartile] = 1 AND ys.[Speed Quartile] = 1) THEN 1 ELSE 0 END) AS [# of Three-Tool Players]
FROM
	YearlyStats_Qualified as ys
GROUP BY
	ys.TeamName
ORDER BY
	[# of Three-Tool Players] DESC;