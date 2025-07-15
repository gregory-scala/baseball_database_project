# Identifying Baseball Players Skilled in Hitting, Power, and Speed

 This SQL project uses the [Lahman Baseball Database (2023 version)](https://sabr.org/lahman-database/) to identify "three-tool" baseball players. 

A player is defined as "three-tool" if they rank in the top quartile in **batting average** (hitting), **slugging percentage** (power), and **stolen bases** (speed) in a given season among players with more than 300 at-bats.

### Views Used

To support this analysis, I construct three views (in sequence):

1. **`playername_view.sql`**
   Creates a table that links a player's `playerID` to their name.
2. **`yearly_position_indicator_view.sql`**
   Assigns a primary position to a player, based on the number of games played by a player at each position in a specific year.
3. **`yearly_batting_stats_view.sql`**
   Calculates a player's offensive statistics by year, taking into account that some baseball players appear on multiple teams in a year.
  
### Final Analyses

Using the views above, I calculate the number of three-tool players across different categories:

1. **`three_tool_players_year.sql`**
   This query calculates the number of "three-tool" baseball players **by year** since 1901.
2. **`three_tool_players_position.sql`**
   This query calculates the number of "three-tool" baseball players by **position**.
3. **`three_tool_players_team.sql`**
   This query calculates the number of "three-tool" baseball players by **team**.

### Requirements
- **SQL Server** (tested with Microsoft SQL Server) with support for:
  - Common Table Expressions (CTEs)
  - Window functions (`NTILE`)
- The Lahman Baseball Database.
