
SELECT * FROM [dbo].[xls cricket data];

-- 1. Which country played the most ODI's in  2018
SELECT TOP 1 Winner AS country, COUNT(*) AS most_ODI_played
FROM [dbo].[xls cricket data]
WHERE Winner in (Team_1, Team_2)
GROUP BY Winner
ORDER BY most_ODI_played DESC;


-- 2. Top 3 countries who won the most ODI's
SELECT TOP 3 Winner, COUNT(*) as win_cnt
FROM [dbo].[xls cricket data]
GROUP BY Winner
ORDER BY win_cnt DESC;


-- 3. How was the performance of Sri Lanka
SELECT Team_1 , Team_2, SUM(CASE WHEN Winner = 'Sri Lanka' THEN 1 END) AS wins,  SUM(CASE WHEN Winner != 'Sri Lanka' THEN 1 END) AS losses
FROM [dbo].[xls cricket data]
WHERE Team_1 = 'Sri Lanka' OR Team_2 = 'Sri Lanka'
GROUP BY Team_1, Team_2;


-- 4. What are the top 3 wins by runs
WITH cte AS (
SELECT Winner, Win_by_Runs, RANK() OVER(PARTITION BY Winner ORDER BY Win_by_Runs DESC) AS rk
FROM [dbo].[xls cricket data]
GROUP BY Winner, Win_by_Runs
)
SELECT Winner, Win_by_Runs
FROM cte
WHERE rk <= 3;


-- 5. Month in which most ODI's were played
SELECT TOP 1 MONTH(Match_Date) AS month, COUNT(*) AS no_of_ODIs
FROM [dbo].[xls cricket data]
GROUP BY MONTH(Match_Date)
ORDER BY no_of_ODIs DESC;


-- 6. How many cricket match were played every month
SELECT MONTH(Match_Date) AS month, COUNT(*) AS no_of_matches
FROM [dbo].[xls cricket data]
GROUP BY MONTH(Match_Date);


-- 7. On which ground most matches were played
SELECT Ground, COUNT(*) AS no_of_matches
FROM [dbo].[xls cricket data]
GROUP BY Ground
ORDER BY no_of_matches DESC


-- 8. Did India win mostly by chasing or playing first
SELECT Team_1 , Team_2, COUNT(Win_by_Runs) AS no_of_wins_by_runs, COUNT(Win_by_Wickets) AS no_of_wins_by_wickets
FROM [dbo].[xls cricket data]
WHERE Team_1 = 'India' OR Team_2 = 'India'
GROUP BY Team_1, Team_2;


-- 9. Top 3 countries who won the most matches in 2018, what was their winning % every month
WITH matches_2018 AS (
SELECT *, FORMAT(Match_Date, 'yyyy-MM') AS YearMonth
FROM [dbo].[xls cricket data]
WHERE YEAR(Match_Date) = 2018
),
wins AS (
SELECT Winner AS Team, YearMonth, COUNT(*) AS Wins
FROM matches_2018
GROUP BY Winner, YearMonth
),
matches_played AS (
SELECT Team_1 AS Team, YearMonth, COUNT(*) AS MatchesPlayed
FROM matches_2018
GROUP BY Team_1, YearMonth
UNION ALL
SELECT Team_2 AS Team, YearMonth, COUNT(*) AS MatchesPlayed
FROM matches_2018
GROUP BY Team_2, YearMonth
),
total_matches_played AS (
SELECT Team, YearMonth, SUM(MatchesPlayed) AS MatchesPlayed
FROM matches_played
GROUP BY Team, YearMonth
),
win_percentages AS (
SELECT w.Team, w.YearMonth, w.Wins, tm.MatchesPlayed, CONCAT((w.Wins / tm.MatchesPlayed) * 100, '%') AS WinPercentage
FROM wins w
JOIN total_matches_played tm ON w.Team = tm.Team AND w.YearMonth = tm.YearMonth
),
annual_wins AS (
SELECT Team, SUM(Wins) AS TotalWins
FROM wins
GROUP BY Team
),
top_teams AS (
SELECT TOP 3 Team
FROM annual_wins
ORDER BY TotalWins DESC
)
SELECT wp.Team, wp.YearMonth, wp.WinPercentage
FROM win_percentages wp
JOIN top_teams tt ON wp.Team = tt.Team
ORDER BY wp.Team, wp.YearMonth;


-- 10. Team which had lost most matches
WITH cte AS (
SELECT CASE 
		WHEN Winner = Team_1 THEN Team_2
		WHEN Winner = Team_2 THEN Team_1 END AS losing_team
FROM [dbo].[xls cricket data]
)
SELECT TOP 1 losing_team, COUNT(*) AS losses
FROM cte
GROUP BY losing_team
ORDER BY losses DESC; 


-- 11. Did this team lost the match by chasing or playing first
WITH cte AS (
SELECT  Win_by_Runs, Win_by_Wickets, 
	CASE 
		WHEN Winner = Team_1 THEN Team_2
		WHEN Winner = Team_2 THEN Team_1 END AS losing_team
FROM [dbo].[xls cricket data]
)
SELECT TOP 1 losing_team, COUNT(*) AS losses, COUNT(Win_by_Runs) AS matches_lost_by_runs, COUNT(Win_by_Wickets) AS matches_lost_by_wickets
FROM cte
GROUP BY losing_team
ORDER BY losses DESC; 


