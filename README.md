# Identifying Baseball Players Skilled in Hitting, Power, and Speed

In this SQL project, I use the [lahman baseball database (2023 version)](https://sabr.org/lahman-database/) to identify "three-tool" baseball players. 

I use batting average to measure a baseball player's skill in hitting, slugging percentage to measure a baseball player's skill in power, and stolen bases to measure a baseball player's skill in speed. I define a baseball player as being "three-tool" if they are in the top quartile amongs all baseball players that specific year (who have more than 300 at bats) in batting average, slugging percentage, and stolen bases. 

To accomplish this project, I make use of three views in sequence.
1. **playernameview.sql**
    - This view creates a table that links a baseball player's playerID to their name.
2. **building_yearly_position_indicator.sql**
    - This view 
