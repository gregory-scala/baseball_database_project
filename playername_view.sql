/* Creating a view that matches a player's name to their player ID */


IF OBJECT_ID('dbo.vw_PlayerInfo', 'V') IS NOT NULL
    DROP VIEW dbo.vw_PlayerInfo;
GO

CREATE VIEW dbo.vw_PlayerInfo AS

SELECT DISTINCT
	playerID,
	nameFirst + ' ' + nameLast as [Name]
FROM
	lahman2023.dbo.People


