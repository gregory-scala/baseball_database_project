/* In this exercise, I calculate the number of three-tool players: players in the top quartile of batting average (hitting), slugging percentage (power), and speed (stolen bases)
by year. I identify a player as having a "tool" if it is in the top quartile in a particular category.*/

/* Ranking players with over 300 at bats in a season by Batting Average (hitting), Slugging Percentage (power), and stolen bases (speed) and dividing them into four quartiles. */
WITH YearlyStats_Qualified AS (
	SELECT *,
	ntile(4) OVER (PARTITION BY yearID
				ORDER BY SLG DESC) as "Power Quartile",
	ntile(4) OVER (PARTITION BY yearID
				ORDER BY BA DESC) as "Hit Quartile",
	ntile(4) OVER (PARTITION BY yearID
				ORDER BY SB DESC) as "Speed Quartile"
	FROM
		lahman2023.dbo.vw_YearlyBattingStats
	WHERE
		AB > 300

)

/* This Query calculates the sum of players in the top quartile of hit, speed, and power by year. */
SELECT
	yearID,
	SUM(CASE WHEN ([Power Quartile] = 1 AND [Hit Quartile] = 1 AND [Speed Quartile] = 1) THEN 1 ELSE 0 END) AS [# of Three-Tool Players]
FROM
	YearlyStats_Qualified
GROUP BY
	yearID
ORDER BY
	yearID DESC;
